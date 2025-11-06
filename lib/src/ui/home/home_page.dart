import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';
import '../partner/partner_view_page.dart';
import '../shared/shared_reflection_page.dart';
import '../checkin/check_in_page.dart';
import '../onboarding/onboarding_page.dart';
import '../auth/sign_in_page.dart';
import '../couple/couple_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isArne = app.mode == UserMode.arne;
    final pages = [
      const CheckInPage(),
      const PartnerViewPage(),
      const SharedReflectionPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Together'),
        actions: [
          TextButton.icon(
            onPressed: () => context.read<AppState>().toggleMode(),
            icon: const Icon(Icons.swap_horiz),
            label: Text(isArne ? 'Arne' : 'Cecilie'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'settings') {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OnboardingPage()),
                );
              } else if (v == 'account') {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                );
              } else if (v == 'couple') {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CouplePage()),
                );
              }
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'account', child: Text('Account')),
              PopupMenuItem(value: 'couple', child: Text('Couple')),
            ],
          )
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sunny), label: 'Check-In'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Partner'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Shared'),
        ],
      ),
      body: SafeArea(
        child: Builder(builder: (context) {
          final s = context.watch<AppState>().settings;
          if (!s.isOnboarded) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Let’s set up Together'),
                    const SizedBox(height: 8),
                    const Text('Add your name and preferences to begin.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OnboardingPage()),
                        );
                      },
                      child: const Text('Start onboarding'),
                    ),
                  ],
                ),
              ),
            );
          }
          return pages[_index];
        }),
      ),
    );
  }
}
