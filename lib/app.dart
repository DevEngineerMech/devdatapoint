import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/features/shell/app_shell.dart';

class DevDatapointApp extends StatelessWidget {
  const DevDatapointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevDatapoint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppShell(),
    );
  }
}