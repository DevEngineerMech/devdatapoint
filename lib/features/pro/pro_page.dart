import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/core/services/iap_service.dart';
import 'package:devdatapoint/core/services/pro_entitlement_service.dart';
import 'package:devdatapoint/features/pro/pages/pro_features_page.dart';
import 'package:devdatapoint/features/pro/pages/pro_receipts_page.dart';
import 'package:devdatapoint/features/pro/widgets/pricing_card.dart';

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 2;
  bool isLoadingStore = true;
  bool isPurchasing = false;
  bool hasPro = false;
  String? activeProductId;
  List<ProductDetails> storeProducts = [];

  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> paidFeatures = const [
    {
      'name': 'Advanced analytics',
      'enabled': true,
      'desc': 'Go deeper into your app performance and growth trends.',
    },
    {
      'name': 'Custom notifications',
      'enabled': true,
      'desc': 'Create smart alerts around the stats that matter to you.',
    },
    {
      'name': 'Multi-app monitoring',
      'enabled': true,
      'desc': 'Track multiple apps in one cleaner workspace.',
    },
    {
      'name': 'AI growth analysis',
      'enabled': true,
      'desc': 'Get AI-powered suggestions to improve your app business.',
    },
    {
      'name': 'Revenue trend insights',
      'enabled': true,
      'desc': 'Understand monetisation performance more clearly.',
    },
    {
      'name': 'Conversion breakdowns',
      'enabled': true,
      'desc': 'See where views are turning into downloads — or not.',
    },
    {
      'name': 'Review sentiment summaries',
      'enabled': true,
      'desc': 'Quickly understand user feedback and pain points.',
    },
    {
      'name': 'Launch performance snapshots',
      'enabled': true,
      'desc': 'Measure how launches and updates affect traction.',
    },
    {
      'name': 'Collaboration (future-ready)',
      'enabled': true,
      'desc': 'Built to expand into shared app workspaces later.',
    },
  ];

  late final List<Map<String, dynamic>> plans = [
    {
      'title': 'Free',
      'productId': null,
      'fallbackPrice': '£0',
      'subtitle': 'Great for getting started with your app tracking.',
      'button': 'Current Plan',
      'highlight': false,
      'features': const [
        {
          'name': 'Basic dashboard',
          'enabled': true,
          'desc': 'See your key app stats in one simple view.',
        },
        {
          'name': 'Manual app tracking',
          'enabled': true,
          'desc': 'Add and organise apps inside your workspace.',
        },
        {
          'name': 'Advanced analytics',
          'enabled': false,
          'desc': 'Unlock deeper growth and performance insights.',
        },
        {
          'name': 'Custom notifications',
          'enabled': false,
          'desc': 'Create your own stat-change alerts.',
        },
        {
          'name': 'AI tools',
          'enabled': false,
          'desc': 'Unlock premium AI features and the AI tab.',
        },
      ],
    },
    {
      'title': 'Monthly',
      'productId': ProEntitlementService.monthlyProductId,
      'fallbackPrice': '£4.99',
      'subtitle': 'Best if you want flexibility while building or testing.',
      'button': 'Upgrade to Monthly',
      'highlight': false,
      'badge': 'FLEXIBLE',
      'features': paidFeatures,
    },
    {
      'title': 'Yearly',
      'productId': ProEntitlementService.yearlyProductId,
      'fallbackPrice': '£19.99',
      'subtitle': 'Best for indie devs actively building and growing apps.',
      'button': 'Upgrade to Yearly',
      'highlight': true,
      'badge': 'MOST USERS CHOOSE YEARLY',
      'savingsText': 'Save £39.89 vs monthly',
      'features': paidFeatures,
    },
    {
      'title': 'Lifetime',
      'productId': ProEntitlementService.lifetimeProductId,
      'fallbackPrice': '£29.99',
      'subtitle': 'Best if you’ll keep building apps long-term.',
      'button': 'Upgrade to Lifetime',
      'highlight': false,
      'badge': 'BEST LONG-TERM',
      'savingsText': 'One-time unlock',
      'features': paidFeatures,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    try {
      final products = await IAPService.loadProducts();
      final entitlement = await ProEntitlementService.hasActiveEntitlement();
      final active = await ProEntitlementService.getActiveProductId();

      if (!mounted) return;

      setState(() {
        storeProducts = products;
        hasPro = entitlement;
        activeProductId = active;
        isLoadingStore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoadingStore = false;
      });
    }
  }

  String _priceForPlan(Map<String, dynamic> plan) {
    final productId = plan['productId'] as String?;
    if (productId == null) return plan['fallbackPrice'];

    try {
      final product = storeProducts.firstWhere((p) => p.id == productId);
      return product.price;
    } catch (_) {
      return plan['fallbackPrice'];
    }
  }

  bool _isCurrentPlan(Map<String, dynamic> plan) {
    final productId = plan['productId'] as String?;
    if (productId == null) return !hasPro;
    return activeProductId == productId;
  }

  Future<void> _buyPlan(Map<String, dynamic> plan) async {
    final productId = plan['productId'] as String?;
    if (productId == null || isPurchasing) return;

    if (!IAPService.isSupportedPlatform) {
      _showMessage(
        'Purchases only work on iPhone/TestFlight builds. Web is just for layout testing.',
      );
      return;
    }

    setState(() => isPurchasing = true);

    try {
      final success = await IAPService.purchaseProduct(productId);

      if (!mounted) return;

      if (success) {
        await _loadStore();
        _showMessage('Pro unlocked successfully.');
      } else {
        _showMessage('Purchase was not completed.');
      }
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isPurchasing = false);
      }
    }
  }

  Future<void> _restore() async {
    if (!IAPService.isSupportedPlatform) {
      _showMessage('Restore only works on iPhone/TestFlight.');
      return;
    }

    if (isPurchasing) return;

    setState(() => isPurchasing = true);

    try {
      final restored = await IAPService.restorePurchases();
      await _loadStore();

      if (!mounted) return;

      if (restored) {
        _showMessage('Purchases restored.');
      } else {
        _showMessage('No purchases were restored.');
      }
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isPurchasing = false);
      }
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
          children: [
            _buildTopBar(context),
            const SizedBox(height: 20),
            _buildPremiumHero(),
            const SizedBox(height: 26),
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All paid plans unlock the exact same Pro features. Choose the payment style that suits you best.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            if (!IAPService.isSupportedPlatform)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Text(
                  'Web mode: UI testing only. Purchases and restores only work on iPhone/TestFlight.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ...List.generate(plans.length, (index) {
              final plan = plans[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: PricingCard(
                  title: plan['title'],
                  price: _priceForPlan(plan),
                  subtitle: _isCurrentPlan(plan)
                      ? 'Current active plan'
                      : plan['subtitle'],
                  buttonText: plan['button'],
                  selected: selectedIndex == index,
                  highlight: plan['highlight'] == true,
                  isCurrent: _isCurrentPlan(plan),
                  isLoading: isLoadingStore && index != 0,
                  isPurchasing: isPurchasing,
                  badge: plan['badge'],
                  savingsText: plan['savingsText'],
                  features:
                      (plan['features'] as List).cast<Map<String, dynamic>>(),
                  onTap: () => setState(() => selectedIndex = index),
                  onUpgrade: () => _buyPlan(plan),
                  onLearnMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProFeaturesPage(),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: isPurchasing ? null : _restore,
                child: Text(
                  isPurchasing ? 'Please wait...' : 'Restore Purchases',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'Business plan support can be added later for teams, more apps and collaboration.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Pro',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProReceiptsPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFFFFD76A),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Receipts',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C1F07),
            Color(0xFF151008),
            Color(0xFF0B0E14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFFFD76A),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              image: const DecorationImage(
                image: AssetImage('assets/images/pro_logo_gold.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'DevDatapoint Pro',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasPro
                ? 'Pro is unlocked. Your premium tools are ready.'
                : 'Premium tools for serious app developers. Understand your growth, react faster, and build with better decisions.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}