import 'dart:math';
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

  /// Returns a map user_id -> display name when available in profiles table.
  /// Missing entries are omitted; callers should fallback to an obfuscated id.
  Future<Map<String, String>> fetchDisplayNames(Iterable<String> userIds) async {
    final ids = userIds.toList();
    if (ids.isEmpty) return {};
    try {
      final res = await client
          .from('profiles')
          .select('id, display_name')
          .inFilter('id', ids);
      final list = (res as List);
      return {
        for (final row in list)
          if ((row as Map<String, dynamic>)['display_name'] != null)
            (row)['id'] as String: (row)['display_name'] as String
      };
    } catch (_) {
      // If table doesn't exist or RLS prevents access, return empty map.
      return {};
    }
  }

  /// Creates or returns a short invite code for a couple, valid until expires_at.
  /// The server enforces uniqueness and expiry. This method generates codes
  /// client-side and retries on conflicts.
  Future<String> generateShortCode(String coupleId, {Duration ttl = const Duration(hours: 48)}) async {
    if (_uid == null) {
      throw StateError('Not authenticated');
    }
    String randomCode(int length) {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no confusing chars
      final rnd = Random.secure();
      return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
    }

    final expiresAt = DateTime.now().toUtc().add(ttl).toIso8601String();
    for (int i = 0; i < 5; i++) {
      final code = randomCode(8);
      try {
        await client.from('short_codes').insert({
          'couple_id': coupleId,
          'code': code,
          'expires_at': expiresAt,
        });
        return code;
      } catch (e) {
        // Unique violation -> retry with a new code, otherwise rethrow
        final msg = '$e';
        if (!msg.contains('duplicate') && !msg.contains('unique')) {
          rethrow;
        }
      }
    }
    throw StateError('Could not generate unique invite code. Please try again.');
  }

  /// Resolves a short code to a couple_id if valid and not expired.
  Future<String?> resolveShortCode(String code) async {
    final res = await client
        .from('short_codes')
        .select('couple_id, expires_at')
        .eq('code', code)
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .maybeSingle();
    if (res == null) return null;
    return res['couple_id'] as String?;
  }
}
