import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_store.dart';
import 'data/repository.dart';
import 'data/supabase_gateway.dart';
import 'data/supabase_repo.dart';
import 'ui/couple/scan_qr_page.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'ui/home/home_page.dart';

class App extends StatelessWidget {
  final CheckInRepository? repositoryOverride;
  const App({super.key, this.repositoryOverride});

  @override
  Widget build(BuildContext context) {
    if (repositoryOverride != null) {
      return _buildWithRepo(repositoryOverride!);
    }
    return FutureBuilder<CheckInRepository>(
      future: _chooseRepository(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final repo = snapshot.data!;
        return _buildWithRepo(repo);
      },
    );
  }

  Widget _buildWithRepo(CheckInRepository repo) {
    return ChangeNotifierProvider(
      create: (_) => AppState(repo)..initialize(),
      child: MaterialApp(
        title: 'Together',
        debugShowCheckedModeBanner: false,
        theme: buildCalmTheme(),
        home: const HomePage(),
        routes: {
          '/scanQr': (_) => const ScanQrPage(),
        },
      ),
    );
  }
}

Future<CheckInRepository> _chooseRepository() async {
  final supa = await SupabaseGateway.ensure();
  if (supa != null && supa.auth.currentSession != null) {
    return SupabaseCheckInRepository(supa);
  }
  return SharedPreferencesCheckInRepository.bootstrap();
}
