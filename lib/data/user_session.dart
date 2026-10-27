import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    this.uid,
  });

  final String name;
  final String email;
  final String phone;
  final String? uid;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? uid,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      uid: uid ?? this.uid,
    );
  }
}

class UserSession {
  UserSession._({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth,
        _firestore = firestore {
    _listenToAuthState();
  }

  static final UserSession instance = UserSession._();

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  FirebaseAuth? get _effectiveAuth {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _effectiveFirestore {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final ValueNotifier<UserProfile?> profile =
      ValueNotifier<UserProfile?>(null);

  bool get isSignedIn => profile.value != null;
  String? get currentUid =>
      profile.value?.uid ?? _effectiveAuth?.currentUser?.uid;

  void _listenToAuthState() {
    try {
      _effectiveAuth?.authStateChanges().listen((user) async {
        if (user == null) {
          profile.value = null;
        } else {
          try {
            await _loadCustomerProfile(user.uid, user.email ?? '');
          } catch (_) {
            profile.value = null;
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _loadCustomerProfile(String uid, String fallbackEmail) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) {
      throw StateError('Firestore service is not initialized.');
    }

    final doc = await firestore.collection('customers').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      profile.value = UserProfile(
        name: data['name'] ?? 'Customer',
        email: data['email'] ?? fallbackEmail,
        phone: data['phoneNumber'] ?? '',
        uid: uid,
      );
    } else {
      // If profile doc doesn't exist yet, seed initial customer record
      await firestore.collection('customers').doc(uid).set({
        'name': 'Customer',
        'email': fallbackEmail,
        'phoneNumber': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      profile.value = UserProfile(
        name: 'Customer',
        email: fallbackEmail,
        phone: '',
        uid: uid,
      );
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanName = name.trim().isEmpty ? 'Customer' : name.trim();
    final cleanPhone = phone.trim();

    final auth = _effectiveAuth;
    if (auth == null) {
      return 'Authentication service is not initialized.';
    }

    final firestore = _effectiveFirestore;
    if (firestore == null) {
      return 'Database service is not initialized.';
    }

    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid == null) {
        return 'Failed to obtain user account identity.';
      }

      await firestore.collection('customers').doc(uid).set({
        'name': cleanName,
        'email': cleanEmail,
        'phoneNumber': cleanPhone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      profile.value = UserProfile(
        name: cleanName,
        email: cleanEmail,
        phone: cleanPhone,
        uid: uid,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed.';
    } on FirebaseException catch (e) {
      return e.message ?? 'Failed to save customer profile.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    final auth = _effectiveAuth;
    if (auth == null) {
      return 'Authentication service is not initialized.';
    }

    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid == null) {
        return 'Failed to verify account identity.';
      }

      await _loadCustomerProfile(uid, cleanEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    final current = profile.value;
    if (current == null) {
      return 'No active customer profile.';
    }

    final newName = name?.trim() ?? current.name;
    final newEmail = email?.trim() ?? current.email;
    final newPhone = phone?.trim() ?? current.phone;

    final uid = current.uid ?? _effectiveAuth?.currentUser?.uid;
    if (uid == null) {
      return 'User is not authenticated.';
    }

    final firestore = _effectiveFirestore;
    if (firestore == null) {
      return 'Database service is not initialized.';
    }

    try {
      await firestore.collection('customers').doc(uid).set({
        'name': newName,
        'email': newEmail,
        'phoneNumber': newPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      profile.value = current.copyWith(
        name: newName,
        email: newEmail,
        phone: newPhone,
      );

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Failed to persist profile updates.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    try {
      await _effectiveAuth?.signOut();
    } catch (_) {}
    profile.value = null;
  }
}
