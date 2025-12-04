// lib/features/4_profile/domain/entities/user_profile.dart
class UserProfile {
  final String? name;
  final String? email;
  final String? description;
  final String? photoUrl;
  final bool loggedIn;

  const UserProfile({
    this.name,
    this.email,
    this.description,
    this.photoUrl,
    this.loggedIn = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? description,
    String? photoUrl,
    bool? loggedIn,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      loggedIn: loggedIn ?? this.loggedIn,
    );
  }
}

// lib/features/4_profile/domain/entities/user_profile.dart
// (kept single definition above)
