import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devdatapoint/app.dart';
import 'package:devdatapoint/core/notifications/notification_service.dart';
import 'package:devdatapoint/core/services/iap_service.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kmyjmpqcmgedtvzxyzul.supabase.co',
    anonKey: 'sb_publishable_J8dUPRGsglH3lWjl5C8PmA_MZ4XS8KX',
  );

  await IAPService.ensureInitialized();
  await NotificationService.initialize();

  await Firebase.initializeApp();

  runApp(const DevDatapointApp());
}