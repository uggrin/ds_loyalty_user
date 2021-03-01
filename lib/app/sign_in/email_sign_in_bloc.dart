import 'dart:async';

import 'package:ds_loyalty_user/app/sign_in/email_sign_in_model.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:flutter/foundation.dart';

class EmailSignInBloc {
  EmailSignInBloc({@required this.auth});
  final AuthBase auth;

  final StreamController<EmailSignInModel> _modelController = StreamController<EmailSignInModel>();
  Stream<EmailSignInModel> get modelStream => _modelController.stream;
  EmailSignInModel _model = EmailSignInModel();

  void dispose() {
    _modelController.close();
  }

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      if (_model.formType == EmailSignInFormType.signIn) {
        await auth.signInEmail(_model.email, _model.password);
      } else {
        await auth.createUser(
          _model.email,
          _model.password,
          _model.fullName,
          _model.birthday,
          _model.country,
          _model.city,
          _model.address,
          _model.phoneNumber,
        );
      }
    } catch (error) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void toggleFormType() {
    final formType = _model.formType == EmailSignInFormType.signIn ? EmailSignInFormType.register : EmailSignInFormType.signIn;
    updateWith(
      email: '',
      password: '',
      fullName: '',
      birthday: '',
      country: '',
      city: '',
      address: '',
      phoneNumber: '',
      formType: formType,
      submitted: false,
      isLoading: false,
    );
  }

  void updateEmail(String email) => updateWith(email: email);

  void updatePassword(String password) => updateWith(password: password);

  void updateName(String fullName) => updateWith(fullName: fullName);

  void updateWith({
    String email,
    String password,
    String fullName,
    String birthday,
    String country,
    String city,
    String address,
    String phoneNumber,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    // update model
    _model = _model.copyWith(
      email: email,
      password: password,
      fullName: fullName,
      birthday: birthday,
      country: country,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
      formType: formType,
      isLoading: isLoading,
      submitted: submitted,
    );
    // add updated model to _modelController
    _modelController.add(_model);
  }
}
