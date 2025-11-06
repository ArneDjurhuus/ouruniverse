import 'dart:convert';

enum Mood { veryLow, low, neutral, good, great }

extension MoodEmoji on Mood {
  String get emoji => switch (this) {
        Mood.veryLow => '😞',
        Mood.low => '🙁',
        Mood.neutral => '😐',
        Mood.good => '🙂',
        Mood.great => '😄',
      };
}

enum OnTrackStatus { yes, no, struggling }

class DailyCheckIn {
  final String id;
  final DateTime createdAt;
  final Mood mood;
  final OnTrackStatus onTrack;
  final String? helped;
  final String? triggers;
  final String? gratitude;
  final bool shareSummary;

  DailyCheckIn({
    required this.id,
    required this.createdAt,
    required this.mood,
    required this.onTrack,
    this.helped,
    this.triggers,
    this.gratitude,
    this.shareSummary = false,
  });

  DailyCheckIn copyWith({
    String? id,
    DateTime? createdAt,
    Mood? mood,
    OnTrackStatus? onTrack,
    String? helped,
    String? triggers,
    String? gratitude,
    bool? shareSummary,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      onTrack: onTrack ?? this.onTrack,
      helped: helped ?? this.helped,
      triggers: triggers ?? this.triggers,
      gratitude: gratitude ?? this.gratitude,
      shareSummary: shareSummary ?? this.shareSummary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'mood': mood.name,
        'onTrack': onTrack.name,
        'helped': helped,
        'triggers': triggers,
        'gratitude': gratitude,
        'shareSummary': shareSummary,
      };

  static DailyCheckIn fromJson(Map<String, dynamic> json) => DailyCheckIn(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        mood: Mood.values.byName(json['mood'] as String),
        onTrack: OnTrackStatus.values.byName(json['onTrack'] as String),
        helped: json['helped'] as String?,
        triggers: json['triggers'] as String?,
        gratitude: json['gratitude'] as String?,
        shareSummary: (json['shareSummary'] as bool?) ?? false,
      );

  static String encodeList(List<DailyCheckIn> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
  static List<DailyCheckIn> decodeList(String src) =>
      (jsonDecode(src) as List).map((e) => DailyCheckIn.fromJson(e)).toList();
}
