import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class SharedReflectionPage extends StatelessWidget {
  const SharedReflectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<AppState>().last7DaySummary();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Shared Reflection Zone', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        _WeeklySummaryCard(
          total: summary.total,
          yes: summary.yes,
          no: summary.no,
          struggling: summary.struggling,
          positivity: summary.positivity,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Shared goals and gratitude (coming soon)'),
                SizedBox(height: 8),
                Text('Voice memos and AI weekly themes will be added in a later milestone.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final int total;
  final int yes;
  final int no;
  final int struggling;
  final double positivity;

  const _WeeklySummaryCard({
    required this.total,
    required this.yes,
    required this.no,
    required this.struggling,
    required this.positivity,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: color.primary),
                const SizedBox(width: 8),
                const Text('This week snapshot'),
                const Spacer(),
                Text('${(positivity * 100).round()}% positive'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Chip('✅ Yes', yes, color.primaryContainer),
                const SizedBox(width: 8),
                _Chip('🟡 Struggling', struggling, color.secondaryContainer),
                const SizedBox(width: 8),
                _Chip('❌ No', no, color.tertiaryContainer),
                const Spacer(),
                Text('$total days'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int value;
  final Color bg;
  const _Chip(this.label, this.value, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text('$label: $value'),
    );
  }
}
