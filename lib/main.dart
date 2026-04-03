import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT ERROR: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };

  await _safeStartup();

  runApp(const DevDatapointApp());
}

Future<void> _safeStartup() async {
  try {
    await Supabase.initialize(
      url: 'https://kmjyjmpqcmgedtvzxyzul.supabase.co',
      anonKey: 'sb_publishable_J8dUPRGsglH3lWjl5C8PmA_MZ4XS8KX',
    );
    debugPrint('Supabase initialised');
  } catch (e, st) {
    debugPrint('Supabase init failed: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    await NotificationService.init();
    debugPrint('Notification service initialised');
  } catch (e, st) {
    debugPrint('Notification init failed: $e');
    debugPrintStack(stackTrace: st);
  }
}