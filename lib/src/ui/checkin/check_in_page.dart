import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/daily_check_in.dart';
import '../../state/app_state.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  Mood? _mood;
  OnTrackStatus _onTrack = OnTrackStatus.yes;
  final _helped = TextEditingController();
  final _triggers = TextEditingController();
  final _gratitude = TextEditingController();
  bool? _share; // defaults to settings on first build

  @override
  void dispose() {
    _helped.dispose();
    _triggers.dispose();
    _gratitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final existing = app.todayEntry;
    _share ??= app.settings.shareByDefault;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Daily Check-In', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              _StreakPill(count: app.currentStreak()),
            ],
          ),
          const SizedBox(height: 16),
          Text('How are you feeling today?'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Mood.values
                .map((m) => ChoiceChip(
                      label: Text(m.emoji),
                      selected: (_mood ?? existing?.mood) == m,
                      onSelected: (_) => setState(() => _mood = m),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Did you stay on track today?'),
          const SizedBox(height: 8),
          SegmentedButton<OnTrackStatus>(
            segments: const [
              ButtonSegment(value: OnTrackStatus.yes, label: Text('Yes')),
              ButtonSegment(value: OnTrackStatus.no, label: Text('No')),
              ButtonSegment(value: OnTrackStatus.struggling, label: Text('Struggling')),
            ],
            selected: {existing?.onTrack ?? _onTrack},
            onSelectionChanged: (s) => setState(() => _onTrack = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _helped,
            decoration: const InputDecoration(labelText: 'What helped you today?'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _triggers,
            decoration: const InputDecoration(labelText: 'Anything triggering or stressful?'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _gratitude,
            decoration: const InputDecoration(labelText: 'Something you’re grateful for today?'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: existing?.shareSummary ?? (_share ?? true),
            onChanged: (v) => setState(() => _share = v),
            title: const Text('Share a brief summary with partner'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save Today'),
              onPressed: (_mood ?? existing?.mood) == null
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final appState = context.read<AppState>();
                      await appState.submitToday(
                        mood: (_mood ?? existing!.mood),
                        onTrack: _onTrack,
                        helped: _helped.text.isEmpty ? existing?.helped : _helped.text,
                        triggers: _triggers.text.isEmpty ? existing?.triggers : _triggers.text,
                        gratitude: _gratitude.text.isEmpty ? existing?.gratitude : _gratitude.text,
                        shareSummary: existing?.shareSummary ?? _share,
                      );
                      messenger.showSnackBar(const SnackBar(content: Text('Saved')));
                      final anchor = appState.takeLastAnchor();
                      if (anchor != null) {
                        messenger.showSnackBar(SnackBar(content: Text('Anchor: $anchor')));
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int count;
  const _StreakPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        const Icon(Icons.local_fire_department, size: 18),
        const SizedBox(width: 4),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
