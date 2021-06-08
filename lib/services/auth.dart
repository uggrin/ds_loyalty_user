import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/services/api_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  User? get currentUser;
  Future<User?> signInAnonimously();
  Future<User?> createUserEmail(String email, String password);
  Future<User> createUser(
    String email,
    String password,
    String? fullName,
    String? birthday,
    String? country,
    String? city,
    String? address,
    String? phoneNumber,
  );
  Future<User?> signInEmail(String email, String password);
  Future<User?> signInGoogle();
  Future<User> signInFacebook();
  Stream<User?> authStateChanges();
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  AccessToken? _accessToken;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signInAnonimously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user;
  }

  @override
  Future<User?> signInEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    return userCredential.user;
  }

  @override
  Future<User?> createUserEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User> createUser(
    String email,
    String password,
    String? fullName,
    String? birthday,
    String? country,
    String? city,
    String? address,
    String? phoneNumber,
  ) async {
    try {
      final User user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user!;

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
      throw (e);
    }
  }

  @override
  Future<User?> signInGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email', "https://www.googleapis.com/auth/userinfo.profile"]);
    final googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        final userCredential = await _firebaseAuth.signInWithCredential(GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ));

        DocumentSnapshot snapshot = await _firestore.collection(APIPath.users()).doc(userCredential.user!.uid).get();
        if (!snapshot.exists) {
          await _firestore.collection(APIPath.users()).doc(userCredential.user!.uid).set({
            'id': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'fullName': userCredential.user!.displayName,
            'photoUrl': googleSignIn.currentUser!.photoUrl ?? 0,
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

  Future<User> signInFacebook() async {
    final result = await FacebookAuth.i.login(
      permissions: ['public_profile', 'email', 'user_birthday', 'user_gender', 'user_location'],
      loginBehavior: LoginBehavior.webOnly,
    );

    if (result.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);

      // Once signed in, return the UserCredentials
      final _userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      DocumentSnapshot snapshot = await _firestore.collection(APIPath.users()).doc(_userCredential.user!.uid).get();

      try {
        final userData = await FacebookAuth.instance.getUserData(fields: 'name,email,picture,birthday,gender,location');

        if (!snapshot.exists) {
          await _firestore.collection(APIPath.users()).doc(_userCredential.user!.uid).set({
            'id': _userCredential.user!.uid,
            'email': userData['email'] ?? '',
            'fullName': _userCredential.user!.displayName,
            'photoUrl': _userCredential.user!.photoURL,
            'birthday': userData['birthday'] ?? '',
            'gender': userData['gender'] ?? '',
            'location': userData['location'] ?? '',
            'totalPoints': 0,
            'accepted_policy': true,
            //'providerData': userCredential.user.providerData,
          });
          return _userCredential.user!;
        }
        return _userCredential.user!;
      } on Exception catch (e) {
        print('fuck $e');
        throw (e);
      }
    }
    throw ('There was an error signing in with Facebook...');
  }

  /*final fbLogin = FacebookLogin();

  Future<User> signInFacebook() async {
    final FacebookLoginResult result = await fbLogin.logIn(["email"]);
    final String token = result.accessToken.token;
    final response = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    final profile = jsonDecode(response.body);
    print(profile);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        DocumentSnapshot snapshot = await _firestore.collection(APIPath.users()).doc(accessToken.userId).get();
        print('User id: ${accessToken.userId} /n Expires: ${accessToken.expires} /n Permissions: ${accessToken.permissions}');
        if (!snapshot.exists) {
          await _firestore.collection(APIPath.users()).doc(accessToken.userId).set({
            'id': accessToken.userId,
            'email': profile['email'],
            'fullName': profile['name'],
            'phoneNumber': '',
            'totalPoints': 0,
            'accepted_policy': true,
            //'photoUrl': userCredential.user.photoURL,
            //'providerData': userCredential.user.providerData,
          });
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }

    return profile;
  }*/

  /*@override
  Future<User> signInFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      // get the user data
      // by default we get the userId, email,name and picture
      //final userData = await FacebookAuth.instance.getUserData();
      final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      final userCredential = await _firebaseAuth.signInWithCredential(FacebookAuthProvider.credential(_accessToken.token));
      print("USER SUCCESS!");
      print(userData);
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
      throw FirebaseAuthException(
        code: 'ERROR_FACEBOOK_LOGIN_FAILED',
        message: result.message,
      );
    } else {
      print("FACEBOOK STATUS" + result.status.toString());
      print("FACEBOOK MESSAGE" + result.message);
      throw UnimplementedError();
    }
  }*/

  // Working version with flutter_facebook_auth: ^1.0.0
  /*Future<User> signInFacebook() async {
    // Trigger the sign-in flow
    final AccessToken result = await FacebookAuth.instance.expressLogin();

    // Create a credential from the access token
    final facebookAuthCredential = FacebookAuthProvider.credential(result.token);

    // Once signed in, return the UserCredential
    final _userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

    DocumentSnapshot snapshot = await _firestore.collection(APIPath.users()).doc(_userCredential.user.uid).get();
    if (!snapshot.exists) {
      await _firestore.collection(APIPath.users()).doc(_userCredential.user.uid).set({
        'id': _userCredential.user.uid,
        'email': _userCredential.user.email,
        'fullName': _userCredential.user.displayName,
        'phoneNumber': _userCredential.user.phoneNumber,
        'totalPoints': 0,
        'accepted_policy': true,
        //'photoUrl': userCredential.user.photoURL,
        //'providerData': userCredential.user.providerData,
      });
    }

    print('USERCREDS');
    print(_userCredential);

    return _userCredential.user;
  }
*/

  Future<void> _logOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _logOut();
    await _firebaseAuth.signOut();
  }
}
