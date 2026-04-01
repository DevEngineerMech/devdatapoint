import 'package:devdatapoint/core/services/pro_entitlement_service.dart';

class ProUnlockService {
  static Future<bool> isProUnlocked() async {
    return await ProEntitlementService.hasActiveEntitlement();
  }

  static Future<bool> shouldShowAiTab() async {
    return await isProUnlocked();
  }

  static Future<List<String>> unlockedModules() async {
    final pro = await isProUnlocked();

    if (!pro) {
      return [
        'dashboard',
        'apps',
        'pro',
        'settings',
      ];
    }

    return [
      'dashboard',
      'apps',
      'ai',
      'pro',
      'settings',
    ];
  }

  static Future<bool> isBusinessUnlocked() async {
    return false;
  }

  static Future<int> allowedAppLimit() async {
    final business = await isBusinessUnlocked();
    if (business) return 999;
    return 5;
  }

  static Future<bool> collaborationEnabled() async {
    final business = await isBusinessUnlocked();
    return business;
  }
}