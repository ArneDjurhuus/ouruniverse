import '../models/daily_check_in.dart';
import 'repository.dart';

class InMemoryCheckInRepository implements CheckInRepository {
  final List<DailyCheckIn> _list = [];

  @override
  Future<DailyCheckIn?> getForDate(DateTime date) async {
    try {
      return _list.firstWhere((e) => e.createdAt.year == date.year && e.createdAt.month == date.month && e.createdAt.day == date.day);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DailyCheckIn>> listAll() async => _list.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<void> upsert(DailyCheckIn entry) async {
    final idx = _list.indexWhere((e) => e.createdAt.year == entry.createdAt.year && e.createdAt.month == entry.createdAt.month && e.createdAt.day == entry.createdAt.day);
    if (idx >= 0) {
      _list[idx] = entry;
    } else {
      _list.add(entry);
    }
  }
}
