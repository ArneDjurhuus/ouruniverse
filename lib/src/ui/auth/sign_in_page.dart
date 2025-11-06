import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/env.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    final authed = session != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!Env.supabaseConfigured) ...[
              const Text('Supabase is not configured.'),
              const SizedBox(height: 8),
              const Text('Run the app with --dart-define SUPABASE_URL and SUPABASE_ANON to enable cloud.'),
            ] else if (authed) ...[
              Text('Signed in as:\n${session.user.email ?? session.user.id}', maxLines: 2),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy
                    ? null
                      : () async {
                        final nav = Navigator.of(context);
                        setState(() => _busy = true);
                        try {
                          await client.auth.signOut();
                          nav.pop();
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                child: const Text('Sign out'),
              ),
            ] else ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              Row(
                children: [
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            setState(() {
                              _busy = true;
                              _error = null;
                            });
                            try {
                              await client.auth.signInWithPassword(
                                email: _email.text.trim(),
                                password: _password.text,
                              );
                              nav.pop();
                            } on AuthException catch (e) {
                              setState(() => _error = e.message);
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            setState(() {
                              _busy = true;
                              _error = null;
                            });
                            try {
                              await client.auth.signUp(
                                email: _email.text.trim(),
                                password: _password.text,
                              );
                              nav.pop();
                            } on AuthException catch (e) {
                              setState(() => _error = e.message);
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
