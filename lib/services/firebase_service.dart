import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication & Firestore Database Service for Medisimbio.
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current authenticated Firebase user.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===========================================================================
  // EMAIL & PASSWORD AUTHENTICATION
  // ===========================================================================

  /// Sign in with Email and Password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register new user with Email, Password, Name, Mobile, DOB, and Gender.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String mobile,
    required String dob,
    required String gender,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Update display name in Firebase Auth profile
        await user.updateDisplayName(name.trim());

        // Save detailed user profile to Firestore
        await saveUserProfile(
          uid: user.uid,
          name: name.trim(),
          email: email.trim(),
          mobile: mobile.trim(),
          dob: dob.trim(),
          gender: gender.trim(),
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Send Password Reset Email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Change password for authenticated email/password user safely.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'No authenticated user found. Please log in again.';
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw 'User account does not have a registered email address.';
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Unable to update password. Please verify your current password.';
    }
  }

  // ===========================================================================
  // GOOGLE SIGN-IN
  // ===========================================================================

  /// Sign in using Google OAuth provider.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled Google sign in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if profile exists in Firestore, if not create default profile
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await saveUserProfile(
            uid: user.uid,
            name: user.displayName ?? 'Google User',
            email: user.email ?? '',
            mobile: user.phoneNumber ?? '',
            dob: '',
            gender: '',
            photoUrl: user.photoURL,
          );
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // ===========================================================================
  // PHONE NUMBER AUTHENTICATION
  // ===========================================================================

  /// Verify phone number and send SMS code.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Complete phone authentication with received OTP code.
  Future<UserCredential> signInWithPhoneOTP({
    required String verificationId,
    required String smsCode,
    String? name,
    String? email,
    String? mobile,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await saveUserProfile(
            uid: user.uid,
            name: name?.trim() ?? 'Phone User',
            email: email?.trim() ?? '',
            mobile: mobile?.trim() ?? user.phoneNumber ?? '',
            dob: '',
            gender: '',
          );
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ===========================================================================
  // FIRESTORE USER PROFILE OPERATIONS
  // ===========================================================================

  /// Save or update user profile document in Firestore (`users/{uid}`).
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required String mobile,
    required String dob,
    required String gender,
    String? photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'mobile': mobile,
        'dob': dob,
        'gender': gender,
        'photoUrl': photoUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving user profile to Firestore: $e');
      }
      rethrow;
    }
  }

  /// Get user profile document from Firestore.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
      String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user profile: $e');
      }
      rethrow;
    }
  }

  /// Real-time stream of user profile data.
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // ===========================================================================
  // SIGN OUT
  // ===========================================================================

  /// Sign out current user from Firebase & Google.
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ===========================================================================
  // HELPER EXCEPTION PARSER
  // ===========================================================================

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect credentials. Please check your details and try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Console.';
      case 'weak-password':
        return 'The password is too weak (min 6 characters).';
      case 'invalid-phone-number':
        return 'The provided phone number is invalid.';
      case 'invalid-verification-code':
        return 'The OTP verification code entered is invalid.';
      case 'invalid-verification-id':
        return 'The verification session has expired. Please try again.';
      case 'too-many-requests':
      case 'quota-exceeded':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication error occurred (${e.code}).';
    }
  }
}
