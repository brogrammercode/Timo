import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/firebase.dart';
import '../../../services/local_storage.dart';
import '../../../utils/error.dart';
import '../../../utils/try_catch.dart';
import '../models/user_model.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthRepo {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LocalStorage _localStorage;

  AuthRepo({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required LocalStorage localStorage,
  })  : _auth = auth,
        _firestore = firestore,
        _localStorage = localStorage;

  User? get currentUser => _auth.currentUser;

  TaskResult<UserModel?> getCurrentUserProfile() async {
    return tryCatchAsync(() async {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }
      
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();
          
      if (!doc.exists) {
        return null;
      }
      
      return UserModel.fromJson(doc.data()!);
    });
  }

  TaskResult<UserModel> signInWithGoogle() async {
    return tryCatchAsync(() async {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw const AuthException('Sign in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw const AuthException('Sign in failed');
      }

      // Check if user profile exists
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      } else {
        // Return a shell model that needs profile setup
        return UserModel(
          id: userCredential.user!.uid,
          userName: '',
          avatarUrl: '',
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );
      }
    });
  }

  TaskResult<UserModel> completeProfileSetup(String username, String avatarUrl) async {
    return tryCatchAsync(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      // Check for uniqueness in a real app, but omitting complex queries here for simplicity
      final query = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('user_name', isEqualTo: username)
          .get();

      if (query.docs.isNotEmpty && query.docs.first.id != user.uid) {
        throw const ValidationException('Username is already taken');
      }

      final now = DateTime.now().toUtc();
      final userModel = UserModel(
        id: user.uid,
        userName: username,
        avatarUrl: avatarUrl,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    });
  }

  TaskResult<void> logout() async {
    return tryCatchAsync(() async {
      await _auth.signOut();
      await _localStorage.clearActiveSessionId();
    });
  }
}

