import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:devdatapoint/core/services/pro_entitlement_service.dart';

class IAPService {
  static const String monthlyProductId = ProEntitlementService.monthlyProductId;
  static const String yearlyProductId = ProEntitlementService.yearlyProductId;
  static const String lifetimeProductId = ProEntitlementService.lifetimeProductId;

  static const Set<String> _productIds = {
    monthlyProductId,
    yearlyProductId,
    lifetimeProductId,
  };

  static final InAppPurchase _iap = InAppPurchase.instance;

  static bool _initialized = false;
  static bool _initializing = false;
  static bool _storeAvailable = false;
  static bool _productsLoaded = false;

  static StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  static List<ProductDetails> _cachedProducts = [];

  static Completer<bool>? _purchaseCompleter;
  static Completer<bool>? _restoreCompleter;

  static bool get isSupportedPlatform => !kIsWeb && Platform.isIOS;

  static Future<void> ensureInitialized() async {
    if (_initialized || _initializing) return;

    _initializing = true;

    if (!isSupportedPlatform) {
      _initialized = true;
      _initializing = false;
      _storeAvailable = false;
      return;
    }

    try {
      _storeAvailable = await _iap.isAvailable();

      if (_storeAvailable) {
        _purchaseSubscription = _iap.purchaseStream.listen(
          _handlePurchaseUpdates,
          onDone: () {
            _purchaseSubscription?.cancel();
          },
          onError: (Object error) {
            debugPrint('Purchase stream error: $error');
            _purchaseCompleter?.complete(false);
            _purchaseCompleter = null;
            _restoreCompleter?.complete(false);
            _restoreCompleter = null;
          },
        );

        await _loadProductsInternal();
      }
    } catch (e) {
      debugPrint('IAP init failed: $e');
      _storeAvailable = false;
    }

    _initialized = true;
    _initializing = false;
  }

  static Future<bool> isStoreAvailable() async {
    await ensureInitialized();
    return _storeAvailable;
  }

  static Future<List<ProductDetails>> loadProducts({bool force = false}) async {
    await ensureInitialized();

    if (!_storeAvailable) {
      _cachedProducts = [];
      return _cachedProducts;
    }

    if (_productsLoaded && !force) {
      return _cachedProducts;
    }

    return _loadProductsInternal();
  }

  static Future<List<ProductDetails>> _loadProductsInternal() async {
    if (!_storeAvailable) {
      _cachedProducts = [];
      return _cachedProducts;
    }

    try {
      final response = await _iap
          .queryProductDetails(_productIds)
          .timeout(const Duration(seconds: 12));

      if (response.error != null) {
        debugPrint('IAP query error: ${response.error}');
        _cachedProducts = [];
        return _cachedProducts;
      }

      _cachedProducts = response.productDetails;
      _productsLoaded = true;
      return _cachedProducts;
    } catch (e) {
      debugPrint('IAP load products failed: $e');
      _cachedProducts = [];
      return _cachedProducts;
    }
  }

  static List<ProductDetails> getCachedProducts() => _cachedProducts;

  static ProductDetails? getProductById(String productId) {
    try {
      return _cachedProducts.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> purchaseProduct(String productId) async {
    await ensureInitialized();

    if (!isSupportedPlatform || !_storeAvailable) {
      throw Exception(
        'Purchases only work on iPhone/TestFlight/App Store builds.',
      );
    }

    if (_cachedProducts.isEmpty) {
      await loadProducts(force: true);
    }

    final product = getProductById(productId);
    if (product == null) {
      throw Exception('Product not found in App Store Connect: $productId');
    }

    _purchaseCompleter = Completer<bool>();
    final purchaseParam = PurchaseParam(productDetails: product);

    await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    return _purchaseCompleter!.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        _purchaseCompleter = null;
        return false;
      },
    );
  }

  static Future<bool> restorePurchases() async {
    await ensureInitialized();

    if (!isSupportedPlatform || !_storeAvailable) {
      throw Exception(
        'Restore only works on iPhone/TestFlight/App Store builds.',
      );
    }

    _restoreCompleter = Completer<bool>();
    await _iap.restorePurchases();

    return _restoreCompleter!.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        _restoreCompleter = null;
        return false;
      },
    );
  }

  static Future<void> openManageSubscriptions() async {
    if (!isSupportedPlatform) return;

    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not open Apple subscription management.');
    }
  }

  static Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    bool restoredAnything = false;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchase.error}');
        _purchaseCompleter?.complete(false);
        _purchaseCompleter = null;
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        _purchaseCompleter?.complete(false);
        _purchaseCompleter = null;
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final purchaseDate = _parsePurchaseDate(purchase.transactionDate);
        final product = getProductById(purchase.productID);

        await ProEntitlementService.saveEntitlement(
          productId: purchase.productID,
          purchaseDate: purchaseDate,
          priceLabel: product?.price ?? '',
          planLabel: product?.title ?? purchase.productID,
        );

        if (purchase.status == PurchaseStatus.purchased) {
          _purchaseCompleter?.complete(true);
          _purchaseCompleter = null;
        }

        if (purchase.status == PurchaseStatus.restored) {
          restoredAnything = true;
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    if (restoredAnything) {
      _restoreCompleter?.complete(true);
      _restoreCompleter = null;
    }
  }

  static DateTime _parsePurchaseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.now();

    final millis = int.tryParse(raw);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }

    return DateTime.now();
  }

  static Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _initialized = false;
    _initializing = false;
    _productsLoaded = false;
    _cachedProducts = [];
  }
}