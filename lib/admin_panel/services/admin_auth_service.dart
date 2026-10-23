import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  AdminAuthService({
    FirebaseAuth? auth,
  }) : _customAuth = auth;

  final FirebaseAuth? _customAuth;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static bool hasAdminClaim(Map<String, dynamic>? claims) {
    return claims?['admin'] == true;
  }

  User? get currentAdmin {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _auth?.authStateChanges() ?? const Stream.empty();
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
      final auth = _auth;
      if (auth == null) {
        return 'Authentication service is not initialized.';
      }

      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      final token = await user?.getIdTokenResult(true);

      if (user == null || !hasAdminClaim(token?.claims)) {
        await _auth?.signOut();
        return 'This account is not authorized for the admin dashboard.';
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
    return 'Admin accounts must be provisioned by an organization owner. '
        'Create the user in Firebase Authentication, then grant the admin '
        'custom claim from a trusted backend before signing in.';
  }

  /// Send password reset email
  Future<String?> sendPasswordReset(String email) async {
    try {
      final auth = _auth;
      if (auth == null) {
        return 'Authentication service is not initialized.';
      }
      await auth.sendPasswordResetEmail(email: email.trim());
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
      await _auth?.signOut();
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
