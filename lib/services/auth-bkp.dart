/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/services/api_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  User get currentUser;
  Future<User> signInAnonimously();
  Future<User> createUserEmail(String email, String password);
  Future<User> createUser(
    String email,
    String password,
    String fullName,
    String birthday,
    String country,
    String city,
    String address,
    String phoneNumber,
  );
  Future<User> signInEmail(String email, String password);
  Future<User> signInGoogle();
  Future<User> signInFacebook();
  Stream<User> authStateChanges();
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Stream<User> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User> signInAnonimously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user;
  }

  @override
  Future<User> signInEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    return userCredential.user;
  }

  @override
  Future<User> createUserEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User> createUser(
    String email,
    String password,
    String fullName,
    String birthday,
    String country,
    String city,
    String address,
    String phoneNumber,
  ) async {
    try {
      final User user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'fullName': fullName,
        'birthday': birthday,
        'country': country,
        'city': city,
        'address': address,
        'phoneNumber': phoneNumber,
        'totalPoints': 0,
      });

      return user;
    } catch (e) {
      print(e);
      print("failed");
    }
  }

  @override
  Future<User> signInGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        final userCredential = await _firebaseAuth.signInWithCredential(GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ));
        DocumentSnapshot snapshot = await _firestore.collection(APIPath.users()).doc(userCredential.user.uid).get();
        if (!snapshot.exists) {
          await _firestore.collection(APIPath.users()).doc(userCredential.user.uid).set({
            'id': userCredential.user.uid,
            'email': userCredential.user.email,
            'fullName': userCredential.user.displayName,
            'phoneNumber': userCredential.user.phoneNumber,
            'totalPoints': 0,
            'accepted_policy': true,
            //'photoUrl': userCredential.user.photoURL,
            //'providerData': userCredential.user.providerData,
          });
        }
        return userCredential.user;
      } else {
        throw FirebaseAuthException(code: 'ERROR_MISSING_GOODLE_ID_TOKEN', message: 'Missing Google ID token.');
      }
    } else {
      throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user.');
    }
  }

  @override
  Future<User> signInFacebook() async {
    final fb = FacebookLogin();
    final response = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    switch (response.status) {
      case FacebookLoginStatus.Success:
        final accessToken = response.accessToken;
        final userCredential = await _firebaseAuth.signInWithCredential(
          FacebookAuthProvider.credential(accessToken.token),
        );
        return userCredential.user;
      case FacebookLoginStatus.Cancel:
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user.',
        );
      case FacebookLoginStatus.Error:
        throw FirebaseAuthException(
          code: 'ERROR_FACEBOOK_LOGIN_FAILED',
          message: response.error.developerMessage,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    await _firebaseAuth.signOut();
  }
}
*/
