import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/core/services/pro_entitlement_service.dart';

class ProReceiptsPage extends StatefulWidget {
  const ProReceiptsPage({super.key});

  @override
  State<ProReceiptsPage> createState() => _ProReceiptsPageState();
}

class _ProReceiptsPageState extends State<ProReceiptsPage> {
  bool isLoading = true;
  String? planLabel;
  String? priceLabel;
  DateTime? purchaseDate;
  DateTime? expiryDate;
  bool isLifetime = false;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    final label = await ProEntitlementService.getActivePlanLabel();
    final price = await ProEntitlementService.getPurchasePriceLabel();
    final purchase = await ProEntitlementService.getPurchaseDate();
    final expiry = await ProEntitlementService.getExpiryDate();
    final lifetime = await ProEntitlementService.isLifetime();

    if (!mounted) return;

    setState(() {
      planLabel = label;
      priceLabel = price;
      purchaseDate = purchase;
      expiryDate = expiry;
      isLifetime = lifetime;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text(
          'Receipts',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/pro_logo_gold.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: (planLabel == null || purchaseDate == null)
                        ? const Column(
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                color: AppTheme.textMuted,
                                size: 42,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'No Pro purchase found yet.',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Latest Receipt',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _receiptRow('Plan', planLabel ?? '-'),
                              _receiptRow('Price', priceLabel ?? '-'),
                              _receiptRow(
                                'Purchased',
                                DateFormat('dd MMM yyyy, HH:mm')
                                    .format(purchaseDate!),
                              ),
                              _receiptRow(
                                'Expires',
                                isLifetime
                                    ? 'Never (Lifetime)'
                                    : expiryDate != null
                                        ? DateFormat('dd MMM yyyy')
                                            .format(expiryDate!)
                                        : '-',
                              ),
                              _receiptRow(
                                'Status',
                                isLifetime ? 'Active Lifetime' : 'Active',
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}