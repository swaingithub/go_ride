import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/core/theme/app_theme.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/dashboard/application/dashboard_providers.dart';
import 'package:go_ride/features/dashboard/data/spending_limit_repository.dart';
import 'package:go_ride/core/theme/theme_provider.dart';

import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(spendingLimitsProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Settings'),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   // Theme Toggle
                   Card(
                     elevation: 2,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     child: SwitchListTile(
                       title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                       subtitle: const Text('Toggle application appearance'),
                       secondary: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                       value: themeMode == ThemeMode.dark,
                       onChanged: (val) {
                         ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                       },
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   // Original Heading
                   Container(
// ... continue with existing header
                     width: double.infinity,
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF9C27B0)]),
                       borderRadius: BorderRadius.circular(20),
                       boxShadow: [
                         BoxShadow(
                           color: AppTheme.primaryColor.withOpacity(0.3),
                           blurRadius: 20,
                           offset: const Offset(0, 10),
                         )
                       ]
                     ),
                     child: const Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                         SizedBox(height: 12),
                         Text(
                           "Manage Your Budget",
                           style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                         ),
                         SizedBox(height: 4),
                         Text(
                           "Set monthly limits to keep track of your ride expenses.",
                           style: TextStyle(color: Colors.white70),
                         ),
                       ],
                     ),
                   )
                ],
              ),
            ),
          ),
          limitsAsync.when(
            data: (limits) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final type = RideType.values[index];
                      final limit = limits[type] ?? 0.0;
                      
                      return statsAsync.when(
                         data: (stats) {
                           final spent = stats.spendingByType[type] ?? 0.0;
                           return SpendingLimitCard(type: type, limit: limit, spent: spent);
                         },
                         loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                         error: (_, __) => const SizedBox(),
                      );
                    },
                    childCount: RideType.values.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, stack) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
        ],
      ),
    );
  }
}

class SpendingLimitCard extends ConsumerWidget {
  final RideType type;
  final double limit;
  final double spent;

  const SpendingLimitCard({
    super.key,
    required this.type,
    required this.limit,
    required this.spent,
  });

  IconData _getIconForType(RideType type) {
    switch (type) {
      case RideType.mini: return Icons.directions_car;
      case RideType.sedan: return Icons.airport_shuttle;
      case RideType.auto: return Icons.electric_rickshaw;
      case RideType.bike: return Icons.two_wheeler;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate progress
    final double progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final bool isOverLimit = limit > 0 && spent > limit;
    final numFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIconForType(type), color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          limit > 0 ? 'Limit: ${numFormat.format(limit)}' : 'No Limit Set',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                    onPressed: () => _showEditDialog(context, ref),
                  ),
                ],
              ),
              if (limit > 0) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    color: isOverLimit ? Colors.red : (progress > 0.8 ? Colors.orange : Colors.green),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent: ${numFormat.format(spent)}',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: isOverLimit ? Colors.red : Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final newLimit = await showDialog<double>(
      context: context,
      builder: (context) => _EditLimitDialog(type: type, initialValue: limit),
    );
    if (newLimit != null) {
      await ref.read(spendingLimitRepositoryProvider).setLimit(type, newLimit);
    }
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
  // Suggestions for quick entry
  final List<double> _suggestions = [1000, 3000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue > 0 ? widget.initialValue.toStringAsFixed(0) : '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(Icons.edit_note, size: 40, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text('Monthly Limit'),
          Text(widget.type.displayName, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions.map((amt) => ActionChip(
                label: Text('₹${amt.toInt()}'),
                onPressed: () {
                  _controller.text = amt.toInt().toString();
                },
              )).toList(),
            ),
             const SizedBox(height: 8),
             TextButton(
               onPressed: () => _controller.text = "0",
               child: const Text("Remove Limit", style: TextStyle(color: Colors.red)),
             )
          ],
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
          child: const Text('Save Limit'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
