import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Default allowed Admin Access Code (matches the design mockup SNS-ADM-2025)
  static const String validAccessCode = 'SNS-ADM-2025';

  User? get currentAdmin {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Logs in an existing Admin
  Future<String?> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Verify that this user has an admin record in Firestore
      final adminDoc = await _firestore
          .collection('admins')
          .doc(credential.user?.uid)
          .get();

      if (!adminDoc.exists) {
        // Automatically create or mark record if this is the first login
        await _firestore.collection('admins').doc(credential.user?.uid).set({
          'uid': credential.user?.uid,
          'email': credential.user?.email,
          'role': 'admin',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return null; // Success (no error)
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Registers a new Admin account
  Future<String?> registerAdmin({
    required String fullName,
    required String workEmail,
    required String accessCode,
    required String password,
  }) async {
    try {
      // Validate Admin Access Code
      if (accessCode.trim() != validAccessCode) {
        return 'Invalid Admin Access Code. Please obtain the correct code from your organisation owner.';
      }

      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: workEmail.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(fullName.trim());

        // Save admin record in Cloud Firestore
        await _firestore.collection('admins').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName.trim(),
          'workEmail': workEmail.trim(),
          'accessCode': accessCode.trim(),
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Send password reset email
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password or credentials. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this work email.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This admin account has been disabled.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
