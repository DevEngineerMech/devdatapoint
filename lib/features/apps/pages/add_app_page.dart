import 'package:flutter/material.dart';

import 'package:devdatapoint/core/services/api_connection_service.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

class AddAppPage extends StatefulWidget {
  const AddAppPage({super.key});

  @override
  State<AddAppPage> createState() => _AddAppPageState();
}

class _AddAppPageState extends State<AddAppPage> {
  final nameController = TextEditingController();
  final iconUrlController = TextEditingController();
  final appStoreIdController = TextEditingController();
  final bundleIdController = TextEditingController();

  bool isSaving = false;
  bool isProUser = false;
  int appLimit = 1;
  int currentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLimitState();
  }

  Future<void> _loadLimitState() async {
    final pro = await ApiConnectionService.isProUser();
    final limit = await ApiConnectionService.getAppLimit();
    final apps = await ApiConnectionService.getSavedApps();

    if (!mounted) return;

    setState(() {
      isProUser = pro;
      appLimit = limit;
      currentCount = apps.length;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    iconUrlController.dispose();
    appStoreIdController.dispose();
    bundleIdController.dispose();
    super.dispose();
  }

  Future<void> _saveApp() async {
    final name = nameController.text.trim();
    final iconUrl = iconUrlController.text.trim();
    final appStoreId = appStoreIdController.text.trim();
    final bundleId = bundleIdController.text.trim();

    if (name.isEmpty && appStoreId.isEmpty && bundleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least an app name, App Store ID, or Bundle ID'),
        ),
      );
      return;
    }

    if (currentCount >= appLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isProUser
                ? 'You have reached your 5 app Pro limit.'
                : 'Free users can only add 1 app. Upgrade to Pro to add up to 5.',
          ),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final existing = await ApiConnectionService.getSavedApps();

    existing.add({
      'name': name.isEmpty
          ? (bundleId.isNotEmpty ? bundleId : 'Untitled App')
          : name,
      'iconUrl': iconUrl,
      'appStoreId': appStoreId,
      'bundleId': bundleId,
      'downloads': '0',
      'impressions': '0',
      'avgPlayTime': '0',
      'sessions': '0',
    });

    await ApiConnectionService.saveApps(existing);

    if (!mounted) return;

    setState(() => isSaving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final atLimit = currentCount >= appLimit;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Add App',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                isProUser
                    ? 'Pro active • $currentCount / 5 apps used'
                    : 'Free plan • $currentCount / 1 app used',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _field(nameController, 'App name (optional)'),
            const SizedBox(height: 14),
            _field(iconUrlController, 'Logo URL (optional)'),
            const SizedBox(height: 14),
            _field(appStoreIdController, 'App Store ID (optional)'),
            const SizedBox(height: 14),
            _field(bundleIdController, 'Bundle ID (recommended)'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (isSaving || atLimit) ? null : _saveApp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                atLimit
                    ? 'App Limit Reached'
                    : isSaving
                        ? 'Saving...'
                        : 'Save App',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }
}