import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/daily_check_in.dart';
import 'repository.dart';

const _kStoreKey = 'checkins_v1';

class SharedPreferencesCheckInRepository implements CheckInRepository {
  final SharedPreferences prefs;
  SharedPreferencesCheckInRepository(this.prefs);

  static Future<SharedPreferencesCheckInRepository> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesCheckInRepository(prefs);
    await repo._seedIfEmpty();
    return repo;
  }

  Future<void> _seedIfEmpty() async {
    if (!prefs.containsKey(_kStoreKey)) {
      final now = DateTime.now();
      final seed = <DailyCheckIn>[
        DailyCheckIn(
          id: const Uuid().v4(),
          createdAt: now.subtract(const Duration(days: 2)),
          mood: Mood.good,
          onTrack: OnTrackStatus.yes,
          gratitude: 'A calm walk together',
          helped: 'Breathing + tea',
          shareSummary: true,
        ),
        DailyCheckIn(
          id: const Uuid().v4(),
          createdAt: now.subtract(const Duration(days: 1)),
          mood: Mood.neutral,
          onTrack: OnTrackStatus.struggling,
          triggers: 'Busy afternoon',
          helped: 'Short nap',
          shareSummary: true,
        ),
      ];
      await prefs.setString(_kStoreKey, DailyCheckIn.encodeList(seed));
    }
  }

  @override
  Future<List<DailyCheckIn>> listAll() async {
    final raw = prefs.getString(_kStoreKey);
    if (raw == null) return [];
    final list = DailyCheckIn.decodeList(raw)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<void> upsert(DailyCheckIn entry) async {
    final list = await listAll();
    final idx = list.indexWhere((e) => _isSameDay(e.createdAt, entry.createdAt));
    if (idx >= 0) {
      list[idx] = entry.copyWith(id: list[idx].id);
    } else {
      list.add(entry);
    }
    await prefs.setString(_kStoreKey, DailyCheckIn.encodeList(list));
  }

  @override
  Future<DailyCheckIn?> getForDate(DateTime date) async {
    final list = await listAll();
    try {
      return list.firstWhere((e) => _isSameDay(e.createdAt, date));
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
