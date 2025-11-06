// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../config/env.dart';
import '../../data/couple_service.dart';

class CouplePage extends StatefulWidget {
  const CouplePage({super.key});

  @override
  State<CouplePage> createState() => _CouplePageState();
}

class _CouplePageState extends State<CouplePage> {
  String? _coupleId;
  List<String> _members = const [];
  bool _busy = false;
  final _name = TextEditingController();
  final _joinCode = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!Env.supabaseConfigured) return;
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) return;
    final svc = CoupleService(client);
    setState(() => _busy = true);
    try {
      final id = await svc.currentCoupleId();
      List<String> members = const [];
      if (id != null) {
        members = await svc.listMemberIds(id);
      }
      if (!mounted) return;
      setState(() {
        _coupleId = id;
        _members = members;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _joinCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Env.supabaseConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Couple')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Cloud is not configured. Run with SUPABASE_URL and SUPABASE_ANON.'),
          ),
        ),
      );
    }
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Couple')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Please sign in under Account to manage your couple.'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Couple')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            if (_busy) const LinearProgressIndicator(),
            if (_coupleId == null) ...[
              Text('Create a couple', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Optional name (e.g., Arne & Cecilie)'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() {
                          _busy = true;
                          _error = null;
                        });
                        try {
                          final id = await CoupleService(client).createCouple(name: _name.text.trim());
                          setState(() => _coupleId = id);
                          await _refresh();
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _error = '$e');
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                child: const Text('Create couple'),
              ),
              const SizedBox(height: 24),
              Text('Join a couple', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _joinCode,
                decoration: const InputDecoration(labelText: 'Invite code (couple ID)'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() {
                          _busy = true;
                          _error = null;
                        });
                        try {
                          await CoupleService(client).joinCouple(_joinCode.text.trim());
                          await _refresh();
                          messenger.showSnackBar(const SnackBar(content: Text('Joined couple')));
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _error = '$e');
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                child: const Text('Join'),
              ),
            ] else ...[
              Text('Your couple', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SelectableText('ID: $_coupleId'),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final id = _coupleId ?? '';
                      await Clipboard.setData(ClipboardData(text: id));
                      messenger.showSnackBar(const SnackBar(content: Text('Invite code copied')));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy invite code'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh members'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (_coupleId == null) return;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Invite QR'),
                          content: SizedBox(
                            width: 240,
                            height: 240,
                            child: Center(
                              child: QrImageView(
                                data: _coupleId!,
                                version: QrVersions.auto,
                                size: 220,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Show QR'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Members (${_members.length})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._members.map((id) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(id),
                  )),
              const SizedBox(height: 24),
              Text('Join with QR', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        final nav = Navigator.of(context);
                        final code = await nav.pushNamed<String>('/scanQr');
                        if (!mounted) return;
                        if (code != null && code.isNotEmpty) {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() {
                            _busy = true;
                            _error = null;
                          });
                          try {
                            await CoupleService(client).joinCouple(code);
                            await _refresh();
                            messenger.showSnackBar(
                                const SnackBar(content: Text('Joined couple via QR')));
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _error = '$e');
                          } finally {
                            if (mounted) setState(() => _busy = false);
                          }
                        }
                      },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan invite QR'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
