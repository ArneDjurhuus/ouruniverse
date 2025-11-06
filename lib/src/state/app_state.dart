import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/repository.dart';
import '../models/daily_check_in.dart';
import '../models/user.dart';
import '../models/settings.dart';
import '../data/settings_store.dart';

class AppState extends ChangeNotifier {
  final CheckInRepository repo;
  AppState(this.repo);

  UserMode _mode = UserMode.arne;
  List<DailyCheckIn> _entries = const [];
  AppSettings _settings = AppSettings.defaults;
  String? _lastAnchorFired;

  UserMode get mode => _mode;
  List<DailyCheckIn> get entries => _entries;
  AppSettings get settings => _settings;
  String? takeLastAnchor() {
    final m = _lastAnchorFired;
    _lastAnchorFired = null;
    return m;
  }

  Future<void> initialize() async {
    _entries = await repo.listAll();
    final store = await SettingsStore.load();
    _settings = store.get();
    _mode = _settings.mode;
    notifyListeners();
  }

  void toggleMode() {
    _mode = _mode == UserMode.arne ? UserMode.cecilie : UserMode.arne;
    _settings = _settings.copyWith(mode: _mode);
    // Fire and forget save
    SettingsStore.load().then((s) => s.save(_settings));
    notifyListeners();
  }

  DailyCheckIn? get todayEntry {
    final now = DateTime.now();
    try {
      return _entries.firstWhere((e) => _isSameDay(e.createdAt, now));
    } catch (_) {
      return null;
    }
  }

  Future<void> submitToday({
    required Mood mood,
    required OnTrackStatus onTrack,
    String? helped,
    String? triggers,
    String? gratitude,
    bool? shareSummary,
  }) async {
    final now = DateTime.now();
    final existing = todayEntry;
    final entry = (existing ?? DailyCheckIn(id: const Uuid().v4(), createdAt: now, mood: mood, onTrack: onTrack))
        .copyWith(
      mood: mood,
      onTrack: onTrack,
      helped: helped,
      triggers: triggers,
      gratitude: gratitude,
      shareSummary: shareSummary ?? _settings.shareByDefault,
    );
    await repo.upsert(entry);
    _entries = await repo.listAll();
    if (onTrack == OnTrackStatus.struggling && _settings.anchorMessages.isNotEmpty) {
      _lastAnchorFired = _settings.anchorMessages.first;
    }
    notifyListeners();
  }

  int currentStreak() {
    // Count consecutive days ending at the most recent onTrack==yes day (including today if applicable)
    if (_entries.isEmpty) return 0;
    final byDay = _entries.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    int streak = 0;
    DateTime cursor = DateTime.now();
  for (final e in byDay) {
      if (!_isSameDay(e.createdAt, cursor)) {
        // skip past days until we hit the cursor day; break if we jumped more than 1 day
        final diff = DateTime(cursor.year, cursor.month, cursor.day)
            .difference(DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
            .inDays;
        if (diff > 1) break; // gap
        cursor = e.createdAt;
      }
      if (e.onTrack == OnTrackStatus.yes) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  // -------- Summaries --------
  ({int total, int yes, int no, int struggling, double positivity}) last7DaySummary() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final window = _entries.where((e) => e.createdAt.isAfter(cutoff)).toList();
    final total = window.length;
    final yes = window.where((e) => e.onTrack == OnTrackStatus.yes).length;
    final no = window.where((e) => e.onTrack == OnTrackStatus.no).length;
    final struggling = window.where((e) => e.onTrack == OnTrackStatus.struggling).length;
    final positivity = total == 0 ? 0.0 : yes / total;
    return (total: total, yes: yes, no: no, struggling: struggling, positivity: positivity);
  }

  Future<void> saveSettings(AppSettings s) async {
    _settings = s;
    _mode = s.mode;
    final store = await SettingsStore.load();
    await store.save(s);
    notifyListeners();
  }
}
