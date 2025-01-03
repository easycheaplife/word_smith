import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/essay_history.dart';
import '../config/app_strings.dart';
import '../services/history_service.dart';

class HistoryPage extends StatelessWidget {
  final List<EssayHistory> histories;
  final VoidCallback onClearHistories;

  const HistoryPage({
    super.key,
    required this.histories,
    required this.onClearHistories,
  });

  String _getInputSummary(String input) {
    final cleanInput = input.split('\n').first.trim();
    return cleanInput.length > 20
        ? '${cleanInput.substring(0, 20)}...'
        : cleanInput;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: histories.isEmpty
          ? Center(child: Text(AppStrings.emptyHistory))
          : ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final history = histories[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(AppStrings.timeFormat)
                              .format(history.timestamp),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getInputSummary(history.input),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      history.functionType,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${AppStrings.inputLabel}:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(history.input),
                            const SizedBox(height: 16),
                            Text('${AppStrings.outputLabel}:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(history.output),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: histories.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _showClearConfirmDialog(context),
              tooltip: AppStrings.clearHistory,
              child: const Icon(Icons.delete),
            ),
    );
  }

  Future<void> _showClearConfirmDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.clearHistoryTitle),
        content: Text(AppStrings.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppStrings.confirmButton),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      onClearHistories();
    }
  }
}
