import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/dashboard/application/dashboard_providers.dart';
import 'package:go_ride/features/dashboard/data/spending_limit_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(spendingLimitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Limits')),
      body: limitsAsync.when(
        data: (limits) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Set monthly spending limits for each ride category. Keep 0 for no limit.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ...RideType.values.map((type) {
                final currentLimit = limits[type] ?? 0.0;
                return Card(
                  child: ListTile(
                    title: Text(type.displayName),
                    subtitle: Text('Current Limit: \$${currentLimit.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final newLimit = await showDialog<double>(
                          context: context,
                          builder: (context) => _EditLimitDialog(
                            type: type,
                            initialValue: currentLimit,
                          ),
                        );
                        if (newLimit != null) {
                          await ref.read(spendingLimitRepositoryProvider).setLimit(type, newLimit);
                          // Provider should update automatically due to watch
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EditLimitDialog extends StatefulWidget {
  final RideType type;
  final double initialValue;

  const _EditLimitDialog({required this.type, required this.initialValue});

  @override
  State<_EditLimitDialog> createState() => _EditLimitDialogState();
}

class _EditLimitDialogState extends State<_EditLimitDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Limit for ${widget.type.displayName}'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          prefixText: '\$ ',
          labelText: 'Monthly Limit',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final val = double.tryParse(_controller.text);
            if (val != null) {
              Navigator.pop(context, val);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
