import '../models/daily_check_in.dart';

abstract class CheckInRepository {
  Future<List<DailyCheckIn>> listAll();
  Future<DailyCheckIn?> getForDate(DateTime date);
  Future<void> upsert(DailyCheckIn entry);
}
