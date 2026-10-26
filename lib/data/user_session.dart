import 'package:flutter/foundation.dart';

/// The signed-in demo user's profile fields.
///
/// Deliberately just 3 plain strings — there's no backend/account system
/// yet, so this only needs to hold what Sign Up collects and Profile
/// displays/edits.
@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

  UserProfile copyWith({String? name, String? email, String? phone}) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

/// App-wide demo "auth" session — a stand-in for a real backend/account
/// system. `SignUpScreen` writes the entered name/email/phone into this
/// on "Create Account"; `SignInScreen` loads whatever's already here (or
/// seeds a default demo identity, since there's no real account database
/// to look a typed email/phone up against). Profile reads and
/// `EditProfileScreen` writes back through the same instance, and
/// `logout()` clears it and every screen that cares (just Profile, for
/// now) reacts via [profile]'s `ValueNotifier`.
class UserSession {
  UserSession._();

  static final UserSession instance = UserSession._();

  final ValueNotifier<UserProfile?> profile = ValueNotifier<UserProfile?>(null);

  bool get isSignedIn => profile.value != null;

  void signUp({
    required String name,
    required String email,
    required String phone,
  }) {
    profile.value = UserProfile(
      name: name.trim().isEmpty ? 'Guest User' : name.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );
  }

  /// Signing in doesn't look anything up against a real account
  /// database (there isn't one) — it keeps whatever profile this demo
  /// session already has (e.g. from a Sign Up earlier in the same app
  /// run), or seeds a default demo identity from whatever was typed into
  /// the "Email or Phone" field so Profile never shows a hardcoded name.
  void signIn(String emailOrPhone) {
    if (isSignedIn) return;
    final String identifier = emailOrPhone.trim();
    final bool looksLikeEmail = identifier.contains('@');
    profile.value = UserProfile(
      name: 'Guest User',
      email: looksLikeEmail ? identifier : '',
      phone: looksLikeEmail ? '' : identifier,
    );
  }

  void updateProfile({String? name, String? email, String? phone}) {
    final UserProfile? current = profile.value;
    if (current == null) return;
    profile.value = current.copyWith(name: name, email: email, phone: phone);
  }

  void logout() {
    profile.value = null;
  }
}
