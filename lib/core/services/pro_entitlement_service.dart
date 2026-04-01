import 'package:shared_preferences/shared_preferences.dart';

class ProEntitlementService {
  static const String monthlyProductId = 'devdatapoint_pro_monthly';
  static const String yearlyProductId = 'devdatapoint_pro_yearly';
  static const String lifetimeProductId = 'devdatapoint_pro_lifetime';

  static const String _activeProductIdKey = 'pro_active_product_id';
  static const String _purchaseDateMsKey = 'pro_purchase_date_ms';
  static const String _expiryDateMsKey = 'pro_expiry_date_ms';
  static const String _isLifetimeKey = 'pro_is_lifetime';
  static const String _purchasePriceKey = 'pro_purchase_price';
  static const String _purchaseLabelKey = 'pro_purchase_label';

  static Future<void> saveEntitlement({
    required String productId,
    required DateTime purchaseDate,
    required String priceLabel,
    required String planLabel,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final bool isLifetime = productId == lifetimeProductId;
    DateTime? expiry;

    if (!isLifetime) {
      if (productId == monthlyProductId) {
        expiry = purchaseDate.add(const Duration(days: 30));
      } else if (productId == yearlyProductId) {
        expiry = purchaseDate.add(const Duration(days: 365));
      }
    }

    await prefs.setString(_activeProductIdKey, productId);
    await prefs.setInt(_purchaseDateMsKey, purchaseDate.millisecondsSinceEpoch);
    await prefs.setBool(_isLifetimeKey, isLifetime);
    await prefs.setString(_purchasePriceKey, priceLabel);
    await prefs.setString(_purchaseLabelKey, planLabel);

    if (expiry != null) {
      await prefs.setInt(_expiryDateMsKey, expiry.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_expiryDateMsKey);
    }
  }

  static Future<void> clearEntitlement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeProductIdKey);
    await prefs.remove(_purchaseDateMsKey);
    await prefs.remove(_expiryDateMsKey);
    await prefs.remove(_isLifetimeKey);
    await prefs.remove(_purchasePriceKey);
    await prefs.remove(_purchaseLabelKey);
  }

  static Future<void> revokeIfExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final isLifetime = prefs.getBool(_isLifetimeKey) ?? false;
    if (isLifetime) return;

    final expiryMs = prefs.getInt(_expiryDateMsKey);
    if (expiryMs == null) return;

    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    if (DateTime.now().isAfter(expiry)) {
      await clearEntitlement();
    }
  }

  static Future<bool> hasActiveEntitlement() async {
    await revokeIfExpired();

    final prefs = await SharedPreferences.getInstance();
    final isLifetime = prefs.getBool(_isLifetimeKey) ?? false;
    if (isLifetime) return true;

    final expiryMs = prefs.getInt(_expiryDateMsKey);
    if (expiryMs == null) return false;

    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    return DateTime.now().isBefore(expiry);
  }

  static Future<String?> getActiveProductId() async {
    await revokeIfExpired();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProductIdKey);
  }

  static Future<DateTime?> getPurchaseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_purchaseDateMsKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<DateTime?> getExpiryDate() async {
    await revokeIfExpired();
    final prefs = await SharedPreferences.getInstance();
    final isLifetime = prefs.getBool(_isLifetimeKey) ?? false;
    if (isLifetime) return null;

    final expiryMs = prefs.getInt(_expiryDateMsKey);
    if (expiryMs == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiryMs);
  }

  static Future<bool> isLifetime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLifetimeKey) ?? false;
  }

  static Future<String?> getActivePlanLabel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_purchaseLabelKey);
  }

  static Future<String?> getPurchasePriceLabel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_purchasePriceKey);
  }
}