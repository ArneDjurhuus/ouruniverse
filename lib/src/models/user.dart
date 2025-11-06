enum UserMode { arne, cecilie }

class UserProfile {
  final String name;
  final UserMode mode;
  final bool partnerCanSeeSummaries; // privacy default

  const UserProfile({
    required this.name,
    required this.mode,
    this.partnerCanSeeSummaries = true,
  });

  UserProfile copyWith({String? name, UserMode? mode, bool? partnerCanSeeSummaries}) =>
      UserProfile(
        name: name ?? this.name,
        mode: mode ?? this.mode,
        partnerCanSeeSummaries: partnerCanSeeSummaries ?? this.partnerCanSeeSummaries,
      );
}
