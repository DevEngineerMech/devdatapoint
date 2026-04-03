import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:devdatapoint/core/services/api_connection_service.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

class LinkApiPage extends StatefulWidget {
  const LinkApiPage({super.key});

  @override
  State<LinkApiPage> createState() => _LinkApiPageState();
}

class _LinkApiPageState extends State<LinkApiPage> {
  int stepIndex = 0;
  bool isSaving = false;
  bool isProUser = false;
  int appLimit = 1;
  String? pickedP8FileName;

  final issuerIdController = TextEditingController();
  final keyIdController = TextEditingController();
  final vendorNumberController = TextEditingController();
  final privateKeyController = TextEditingController();

  final appNameController = TextEditingController();
  final appIconUrlController = TextEditingController();
  final appStoreIdController = TextEditingController();
  final bundleIdController = TextEditingController();

  final List<Map<String, String>> apps = [];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final connection = await ApiConnectionService.getConnection();
    final savedApps = await ApiConnectionService.getSavedApps();
    final pro = await ApiConnectionService.isProUser();
    final limit = await ApiConnectionService.getAppLimit();

    issuerIdController.text = connection['issuerId'] ?? '';
    keyIdController.text = connection['keyId'] ?? '';
    vendorNumberController.text = connection['vendorNumber'] ?? '';
    privateKeyController.text = connection['privateKey'] ?? '';

    apps
      ..clear()
      ..addAll(savedApps);

    if (mounted) {
      setState(() {
        isProUser = pro;
        appLimit = limit;
      });
    }
  }

  @override
  void dispose() {
    issuerIdController.dispose();
    keyIdController.dispose();
    vendorNumberController.dispose();
    privateKeyController.dispose();
    appNameController.dispose();
    appIconUrlController.dispose();
    appStoreIdController.dispose();
    bundleIdController.dispose();
    super.dispose();
  }

  Future<void> _pickP8File() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['p8', 'txt'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final Uint8List? bytes = file.bytes;

      if (bytes == null) {
        _showSnack('Could not read selected file.');
        return;
      }

      final text = String.fromCharCodes(bytes).trim();

      if (text.isEmpty) {
        _showSnack('Selected file was empty.');
        return;
      }

      privateKeyController.text = text;
      pickedP8FileName = file.name;

      if (mounted) setState(() {});
    } catch (e) {
      _showSnack('File picker failed: $e');
    }
  }

  void _addApp() {
    final name = appNameController.text.trim();
    final iconUrl = appIconUrlController.text.trim();
    final appStoreId = appStoreIdController.text.trim();
    final bundleId = bundleIdController.text.trim();

    if (apps.length >= appLimit) {
      _showSnack(
        isProUser
            ? 'You can only add up to 5 apps on Pro.'
            : 'Free users can only add 1 app. Upgrade to Pro to add up to 5.',
      );
      return;
    }

    if (name.isEmpty && bundleId.isEmpty && appStoreId.isEmpty) {
      _showSnack(
        'Add at least an app name, bundle ID, or App Store ID.',
      );
      return;
    }

    apps.add({
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

    appNameController.clear();
    appIconUrlController.clear();
    appStoreIdController.clear();
    bundleIdController.clear();

    setState(() {});
  }

  Future<void> _saveAll() async {
    final issuerId = issuerIdController.text.trim();
    final keyId = keyIdController.text.trim();
    final privateKey = privateKeyController.text.trim();

    if (issuerId.isEmpty || keyId.isEmpty || privateKey.isEmpty) {
      _showSnack('Issuer ID, Key ID and private key are required.');
      return;
    }

    setState(() => isSaving = true);

    try {
      await ApiConnectionService.saveConnection(
        issuerId: issuerId,
        keyId: keyId,
        privateKey: privateKey,
        vendorNumber: vendorNumberController.text.trim(),
      );

      await ApiConnectionService.saveApps(apps);

      if (apps.isNotEmpty) {
        try {
          await ApiConnectionService.syncNow();
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() => isSaving = false);

      _showSnack(
        apps.isEmpty
            ? 'API saved. You can add apps later.'
            : 'API linked and apps saved.',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);
      _showSnack('Save failed: $e');
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _nextStep() {
    if (stepIndex < 4) {
      setState(() => stepIndex += 1);
    }
  }

  void _previousStep() {
    if (stepIndex > 0) {
      setState(() => stepIndex -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _stepIssuerId(),
      _stepKeyId(),
      _stepVendorNumber(),
      _stepPrivateKey(),
      _stepApps(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Link Apple API',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _stepProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: steps[stepIndex],
              ),
            ),
            _bottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _stepProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: List.generate(5, (index) {
          final active = index == stepIndex;
          final complete = index < stepIndex;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
              height: 8,
              decoration: BoxDecoration(
                color: complete || active
                    ? AppTheme.primary
                    : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _bottomControls() {
    final isLast = stepIndex == 4;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (stepIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          if (stepIndex > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving
                  ? null
                  : isLast
                      ? _saveAll
                      : _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isSaving
                    ? 'Saving...'
                    : isLast
                        ? 'Save & Continue'
                        : 'Next',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _infoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 8,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIssuerId() {
    return _stepCard(
      title: 'Step 1 — Issuer ID',
      subtitle:
          'Open App Store Connect → Users and Access → Keys, then copy your Issuer ID.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBullet('This tells DevDatapoint which Apple account to read from.'),
          _infoBullet('You only need to set this up once.'),
          _infoBullet('You can edit it later if you change keys.'),
          const SizedBox(height: 8),
          _darkField(
            controller: issuerIdController,
            hint: 'Paste Issuer ID',
          ),
        ],
      ),
    );
  }

  Widget _stepKeyId() {
    return _stepCard(
      title: 'Step 2 — Key ID',
      subtitle:
          'Still in the Keys area, copy the Key ID for the App Store Connect API key you created.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBullet('This identifies the exact API key you generated.'),
          _infoBullet('Use the same key that belongs to your App Store Connect account.'),
          _infoBullet('You can revoke and replace it later if needed.'),
          const SizedBox(height: 8),
          _darkField(
            controller: keyIdController,
            hint: 'Paste Key ID',
          ),
        ],
      ),
    );
  }

  Widget _stepVendorNumber() {
    return _stepCard(
      title: 'Step 3 — Vendor Number',
      subtitle:
          'Optional for now. If you know your vendor number, save it here. You can leave it blank.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBullet('Useful for some Apple reporting setups.'),
          _infoBullet('Safe to skip for now if you just want to get started.'),
          _infoBullet('You can come back and add it later.'),
          const SizedBox(height: 8),
          _darkField(
            controller: vendorNumberController,
            hint: 'Optional Vendor Number',
          ),
        ],
      ),
    );
  }

  Widget _stepPrivateKey() {
    return _stepCard(
      title: 'Step 4 — Private Key (.p8)',
      subtitle:
          'Upload your .p8 file or paste it manually. Both work.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBullet('Tap the upload button to pick your downloaded .p8 file.'),
          _infoBullet('Or paste the full key manually if you prefer.'),
          _infoBullet('Keep the BEGIN and END lines included.'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickP8File,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: AppTheme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.upload_file_rounded, color: AppTheme.textPrimary),
              label: Text(
                pickedP8FileName == null
                    ? 'Choose .p8 File'
                    : 'Loaded: $pickedP8FileName',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _darkField(
            controller: privateKeyController,
            hint: 'Paste full .p8 private key here',
            maxLines: 12,
          ),
        ],
      ),
    );
  }

  Widget _stepApps() {
    return _stepCard(
      title: 'Step 5 — Add Your Apps (Optional)',
      subtitle:
          'You can add apps now or skip this and do it later from the Apps page.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBullet('Free users can add 1 app. Pro users can add up to 5 apps.'),
          _infoBullet('Bundle ID is usually the most useful field to add.'),
          _infoBullet('App name and logo are optional.'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              isProUser
                  ? 'Pro active • ${apps.length}/5 apps used'
                  : 'Free plan • ${apps.length}/1 app used',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _darkField(
            controller: appNameController,
            hint: 'App name (optional)',
          ),
          const SizedBox(height: 12),
          _darkField(
            controller: appIconUrlController,
            hint: 'Logo URL (optional)',
          ),
          const SizedBox(height: 12),
          _darkField(
            controller: appStoreIdController,
            hint: 'App Store ID (required)',
          ),
          const SizedBox(height: 12),
          _darkField(
            controller: bundleIdController,
            hint: 'Bundle ID (required)',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _addApp,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: AppTheme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Add App',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (apps.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No apps added yet. That’s okay — you can save and continue later.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          else
            ...List.generate(apps.length, (index) {
              final app = apps[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        app['name'] ?? '',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        apps.removeAt(index);
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}