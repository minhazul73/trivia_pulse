import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_config.dart';
import '../utils/utils.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _firebaseAuth => AppConfig.firebaseAuth;

  GoogleSignIn get _googleSignIn => AppConfig.googleSignIn;

  /// Stream of auth state changes. Emits the current user map or null.
  Stream<Map<String, dynamic>?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return {
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL,
      };
    });
  }

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      final user = credentials.user;
      if (user == null) return null;
      return {
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL,
      };
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      final user = credentials.user;
      if (user == null) return null;
      await user.updateDisplayName(name);
      return {
        'id': user.uid,
        'email': user.email ?? '',
        'name': name,
        'photoUrl': user.photoURL,
      };
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await _firebaseAuth.signOut();
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return {
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL,
      };
    });
  }

  FutureEither<Map<String, dynamic>?> signInWithGoogle() async {
    return runTask(() async {
      _initGoogleSignIn();
      final googleUser = await _googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      final GoogleSignInClientAuthorization? authorization = await authorizationClient.authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;

      if (idToken == null || accessToken == null) {
        throw Exception('Google Sign In Failed: Missing ID or Access Token');
      }

      final firebaseCredentials = await _firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken, accessToken: accessToken),
      );
      
      final user = firebaseCredentials.user;
      if (user == null) return null;
      return {
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL,
      };
    }, requiresNetwork: true);
  }
  
  void _initGoogleSignIn() {
    unawaited(
      _googleSignIn.initialize(
        clientId: AppConfig.googleClientId,
        serverClientId: AppConfig.serverClientId,
      ),
    );
  }
}
