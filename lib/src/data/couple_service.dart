import 'package:supabase_flutter/supabase_flutter.dart';

class CoupleService {
  final SupabaseClient client;
  CoupleService(this.client);

  String? get _uid => client.auth.currentUser?.id;

  Future<String?> currentCoupleId() async {
    if (_uid == null) return null;
    final res = await client
        .from('couple_members')
        .select('couple_id')
        .eq('user_id', _uid!)
        .limit(1);
    if ((res as List).isEmpty) return null;
  return (res.first)['couple_id'] as String?;
  }

  Future<String> createCouple({String? name}) async {
    if (_uid == null) {
      throw StateError('Not authenticated');
    }
    final res = await client.from('couples').insert({
      if (name != null && name.isNotEmpty) 'name': name,
    }).select('id').single();
    return (res['id'] as String);
  }

  Future<void> joinCouple(String coupleId) async {
    if (_uid == null) {
      throw StateError('Not authenticated');
    }
    await client.from('couple_members').insert({
      'couple_id': coupleId,
      'user_id': _uid,
      'role': 'member',
    });
  }

  Future<List<String>> listMemberIds(String coupleId) async {
    final res = await client
        .from('couple_members')
        .select('user_id')
        .eq('couple_id', coupleId);
    return (res as List)
        .map((e) => (e as Map<String, dynamic>)['user_id'] as String)
        .toList();
  }
}
