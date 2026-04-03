import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:devdatapoint/app.dart';
import 'package:devdatapoint/core/notifications/notification_service.dart';
import 'package:devdatapoint/core/services/iap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runZonedGuarded(() async {
    await _safeStartup();
    runApp(const DevDatapointApp());
  }, (error, stack) {
    debugPrint('UNCAUGHT STARTUP ERROR: $error');
    debugPrintStack(stackTrace: stack);
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Startup failed:\\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  });
}

Future<void> _safeStartup() async {
  // Supabase
  try {
    await Supabase.initialize(
      url: 'https://kmyjmpqcmgedtvzxyzul.supabase.co',
      anonKey: 'sb_publishable_J8dUPRGsglH3lWjl5C8PmA_MZ4XS8KX',
    );
    debugPrint('Supabase initialized');
  } catch (e, st) {
    debugPrint('Supabase init failed: $e');
    debugPrintStack(stackTrace: st);
  }

  // Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized');
  } catch (e, st) {
    debugPrint('Firebase init failed: $e');
    debugPrintStack(stackTrace: st);
  }

  // IAP
  try {
    await IAPService.ensureInitialized();
    debugPrint('IAP initialized');
  } catch (e, st) {
    debugPrint('IAP init failed: $e');
    debugPrintStack(stackTrace: st);
  }

  // Notifications
  try {
    await NotificationService.initialize();
    debugPrint('Notifications initialized');
  } catch (e, st) {
    debugPrint('Notification init failed: $e');
    debugPrintStack(stackTrace: st);
  }
}