import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/daily_check_in.dart';
import '../../state/app_state.dart';

class PartnerViewPage extends StatelessWidget {
  const PartnerViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AppState>().entries.where((e) => e.shareSummary).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final today = context.watch<AppState>().todayEntry;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('Partner View', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            _StatusChip(entry: today),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const Text('No shared summaries yet.')
        else
          ...entries.take(10).map((e) => _SummaryTile(entry: e)),
        const SizedBox(height: 24),
        Text('Send a supportive note', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _EncourageChip('Proud of you 💚'),
            _EncourageChip('I’m here with you 🤝'),
            _EncourageChip('Let’s take a walk 🌿'),
            _EncourageChip('Tea + deep breath? 🍵'),
          ],
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final DailyCheckIn entry;
  const _SummaryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, HH:mm');
    final dateStr = fmt.format(entry.createdAt);
    return Card(
      child: ListTile(
        leading: Text(entry.mood.emoji, style: const TextStyle(fontSize: 24)),
        title: Text(_onTrackText(entry.onTrack)),
        subtitle: Text(entry.gratitude?.isNotEmpty == true
            ? 'Grateful: ${entry.gratitude}'
            : (entry.helped?.isNotEmpty == true ? 'Helped: ${entry.helped}' : '')),
        trailing: Text(dateStr, textAlign: TextAlign.right),
      ),
    );
  }

  String _onTrackText(OnTrackStatus s) => switch (s) {
        OnTrackStatus.yes => '✅ On track',
        OnTrackStatus.no => '❌ Not on track',
        OnTrackStatus.struggling => '🟡 Struggling',
      };
}

class _EncourageChip extends StatelessWidget {
  final String label;
  const _EncourageChip(this.label);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sent: "$label" (demo)'))),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DailyCheckIn? entry;
  const _StatusChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = entry == null
        ? 'No check-in yet'
        : switch (entry!.onTrack) {
            OnTrackStatus.yes => 'Today: ✅',
            OnTrackStatus.no => 'Today: ❌',
            OnTrackStatus.struggling => 'Today: 🟡',
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}
