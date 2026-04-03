import 'package:flutter/material.dart';

import 'features/shell/app_shell.dart';

class DevDatapointApp extends StatelessWidget {
  const DevDatapointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevDatapoint',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1117),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}