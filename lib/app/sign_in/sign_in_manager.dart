import 'dart:async';

import 'package:ds_loyalty_user/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class SignInManager {
  SignInManager({@required this.isLoading, @required this.auth});
  final AuthBase auth;
  final ValueNotifier<bool> isLoading;

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<User> signInGoogle() async => await _signIn(auth.signInGoogle);

  Future<User> signInFacebook() async => await _signIn(auth.signInFacebook);
}
