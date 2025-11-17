// lib/features/4_profile/domain/entities/user_profile.dart
class UserProfile {
  final String? name;
  final String? email;
  final String? description;
  final bool loggedIn;

  const UserProfile({
    this.name,
    this.email,
    this.description,
    this.loggedIn = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? description,
    bool? loggedIn,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      loggedIn: loggedIn ?? this.loggedIn,
    );
  }
}

// lib/features/4_profile/domain/entities/user_profile.dart
// (kept single definition above)
