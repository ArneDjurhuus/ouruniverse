import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/daily_check_in.dart';
import 'repository.dart';

class SupabaseCheckInRepository implements CheckInRepository {
  final SupabaseClient client;
  SupabaseCheckInRepository(this.client);

  String? get _uid => client.auth.currentUser?.id;

  @override
  Future<List<DailyCheckIn>> listAll() async {
    if (_uid == null) return [];
    final res = await client
        .from('checkins')
        .select()
        .order('day', ascending: true);
    return (res as List)
        .map((e) => _fromRow(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DailyCheckIn?> getForDate(DateTime date) async {
    if (_uid == null) return null;
    final dayStr = _day(date);
    final res = await client
        .from('checkins')
        .select()
        .eq('day', dayStr)
        .limit(1);
  if ((res as List).isEmpty) return null;
  return _fromRow(res.first);
  }

  @override
  Future<void> upsert(DailyCheckIn entry) async {
    if (_uid == null) {
      throw StateError('Not authenticated with Supabase');
    }
    final row = _toRow(entry);
    row['user_id'] = _uid; // RLS expects owner
    row['day'] = _day(entry.createdAt);
    await client.from('checkins').upsert(row);
  }

  Map<String, dynamic> _toRow(DailyCheckIn e) => {
        'mood': e.mood.name,
        'on_track': e.onTrack.name,
        'helped': e.helped,
        'triggers': e.triggers,
        'gratitude': e.gratitude,
        'share_summary': e.shareSummary,
      };

  DailyCheckIn _fromRow(Map<String, dynamic> row) {
    final createdAt = DateTime.parse((row['created_at'] ?? '${row['day']}T00:00:00Z') as String);
    return DailyCheckIn(
      id: (row['id'] as String?) ?? '${row['user_id']}_${row['day']}',
      createdAt: createdAt.toLocal(),
      mood: Mood.values.byName(row['mood'] as String),
      onTrack: OnTrackStatus.values.byName(row['on_track'] as String),
      helped: row['helped'] as String?,
      triggers: row['triggers'] as String?,
      gratitude: row['gratitude'] as String?,
      shareSummary: (row['share_summary'] as bool?) ?? false,
    );
  }

  String _day(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
