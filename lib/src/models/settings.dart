import 'user.dart';

class AppSettings {
  final String name;
  final UserMode mode;
  final bool shareByDefault;
  final List<String> anchorMessages;

  const AppSettings({
    required this.name,
    required this.mode,
    this.shareByDefault = true,
    this.anchorMessages = const [
      'Proud of you 💚',
      'I’m here with you 🤝',
      'Let’s take a walk 🌿',
      'Tea + deep breath? 🍵',
    ],
  });

  bool get isOnboarded => name.trim().isNotEmpty;

  AppSettings copyWith({String? name, UserMode? mode, bool? shareByDefault, List<String>? anchorMessages}) =>
      AppSettings(
        name: name ?? this.name,
        mode: mode ?? this.mode,
        shareByDefault: shareByDefault ?? this.shareByDefault,
        anchorMessages: anchorMessages ?? this.anchorMessages,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'mode': mode.name,
        'shareByDefault': shareByDefault,
        'anchorMessages': anchorMessages,
      };

  static AppSettings fromJson(Map<String, dynamic> json) => AppSettings(
        name: (json['name'] as String?) ?? '',
        mode: UserMode.values.byName((json['mode'] as String?) ?? 'arne'),
        shareByDefault: (json['shareByDefault'] as bool?) ?? true,
        anchorMessages: (json['anchorMessages'] as List?)?.cast<String>() ?? const [],
      );

  static const AppSettings defaults = AppSettings(name: '', mode: UserMode.arne);
}
