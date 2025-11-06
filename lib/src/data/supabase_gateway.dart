import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

class SupabaseGateway {
  static bool _initialized = false;

  static Future<SupabaseClient?> ensure() async {
    if (!Env.supabaseConfigured) return null;
    if (!_initialized) {
      await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
      _initialized = true;
    }
    return Supabase.instance.client;
  }
}
