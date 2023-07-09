import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test4/constants/firestore_constants.dart';
import 'package:test4/models/user_chat.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences sharedPreferences;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firebaseFirestore,
    required this.sharedPreferences,
  });

  String? getUserFirebaseId() {
    return sharedPreferences.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn &&
        sharedPreferences.getString(FirestoreConstants.id)?.isNotEmpty ==
            true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(authCredential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();

        final List<DocumentSnapshot> documents = result.docs;

        if (documents.length == 0) {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });
          User? currUser = firebaseUser;
          await sharedPreferences.setString(
              FirestoreConstants.id, currUser.uid);
          await sharedPreferences.setString(
              FirestoreConstants.nickname, currUser.displayName ?? "");
          await sharedPreferences.setString(
              FirestoreConstants.photoUrl, currUser.photoURL ?? "");
        } else {
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          await sharedPreferences.setString(FirestoreConstants.id, userChat.id);
          await sharedPreferences.setString(
              FirestoreConstants.nickname, userChat.nickname);
          await sharedPreferences.setString(
              FirestoreConstants.photoUrl, userChat.photoUrl);
          await sharedPreferences.setString(
              FirestoreConstants.aboutMe, userChat.aboutMe);
        }

        _status = Status.authenticated;

        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;

        notifyListeners();

        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  void handleExceptions() {
    _status = Status.authenticateException;
    notifyListeners();
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}
