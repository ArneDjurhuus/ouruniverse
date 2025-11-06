import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/settings.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _name = TextEditingController();
  UserMode _mode = UserMode.arne;
  bool _shareByDefault = true;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>().settings;
    _name.text = s.name;
    _mode = s.mode;
    _shareByDefault = s.shareByDefault;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set up Together', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 12),
            const Text('Choose your role'),
            const SizedBox(height: 8),
            SegmentedButton<UserMode>(
              segments: const [
                ButtonSegment(value: UserMode.arne, label: Text('Arne')),
                ButtonSegment(value: UserMode.cecilie, label: Text('Cecilie')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _shareByDefault,
              onChanged: (v) => setState(() => _shareByDefault = v),
              title: const Text('Share a brief summary by default'),
              subtitle: const Text('You can change this any time in Settings.'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final settings = AppSettings(
                    name: _name.text.trim(),
                    mode: _mode,
                    shareByDefault: _shareByDefault,
                  );
                  final nav = Navigator.of(context);
                  await context.read<AppState>().saveSettings(settings);
                  nav.pop();
                },
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
