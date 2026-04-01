import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

class GraphPage extends StatefulWidget {
  final String title;
  final List<int> data;

  const GraphPage({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  int selectedRange = 7;

  List<int> get displayedData {
    if (selectedRange == 7) return widget.data;
    if (selectedRange == 30) {
      return List.generate(30, (i) => widget.data.last + i * 3);
    }
    return List.generate(60, (i) => widget.data.last + i * 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _rangeButton(7),
                _rangeButton(30),
                _rangeButton(60, label: 'Lifetime'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: displayedData.length,
                itemBuilder: (_, i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 14,
                    width: displayedData[i].toDouble(),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangeButton(int value, {String? label}) {
    final selected = selectedRange == value;

    return GestureDetector(
      onTap: () => setState(() => selectedRange = value),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          label ?? '$value Days',
          style: TextStyle(
            color: selected ? Colors.black : AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}