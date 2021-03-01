import 'package:ds_loyalty_user/app/sign_in/validators.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:flutter/foundation.dart';

import 'email_sign_in_model.dart';

class EmailSignInChangeModel with EmailAndPasswordValidators, ChangeNotifier {
  EmailSignInChangeModel({
    @required this.auth,
    this.email = '',
    this.password = '',
    this.fullName = '',
    this.birthday = '',
    this.country = '',
    this.city = '',
    this.address = '',
    this.phoneNumber = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });

  final AuthBase auth;

  String email;
  String password;
  String fullName;
  String birthday;
  String country;
  String city;
  String address;
  String phoneNumber;

  EmailSignInFormType formType;
  bool isLoading;
  bool submitted;

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      if (formType == EmailSignInFormType.signIn) {
        await auth.signInEmail(email, password);
      } else {
        await auth.createUser(email, password, fullName, birthday, country, city, address, phoneNumber);
      }
    } catch (error) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryButtonText {
    return formType == EmailSignInFormType.signIn ? 'Sign in' : 'Create an account';
  }

  String get secondaryButtonText {
    return formType == EmailSignInFormType.signIn ? 'Need an account? Register' : 'Have an account? Sign in';
  }

  bool get canRegister {
    return emailValidator.isValid(email) &&
        passwordValidator.isValid(password) &&
        nameValidator.isValid(fullName) &&
        birthdayValidator.isValid(birthday) &&
        countryValidator.isValid(country) &&
        cityValidator.isValid(city) &&
        addressValidator.isValid(address) &&
        phoneValidator.isValid(phoneNumber) &&
        !isLoading;
  }

  bool get canSignIn {
    return emailValidator.isValid(email) && passwordValidator.isValid(password) && !isLoading;
  }

  String get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  String get nameErrorText {
    bool showErrorText = submitted && !nameValidator.isValid(fullName);
    return showErrorText ? invalidNameErrorText : null;
  }

  String get birthdayErrorText {
    bool showErrorText = submitted && !birthdayValidator.isValid(birthday);
    return showErrorText ? invalidBirthdayErrorText : null;
  }

  String get countryErrorText {
    bool showErrorText = submitted && !countryValidator.isValid(country);
    return showErrorText ? countryErrorText : null;
  }

  String get cityErrorText {
    bool showErrorText = submitted && !cityValidator.isValid(city);
    return showErrorText ? cityErrorText : null;
  }

  String get addressErrorText {
    bool showErrorText = submitted && !addressValidator.isValid(address);
    return showErrorText ? addressErrorText : null;
  }

  String get phoneErrorText {
    bool showErrorText = submitted && !phoneValidator.isValid(phoneNumber);
    return showErrorText ? phoneErrorText : null;
  }

  void toggleFormType() {
    final formType = this.formType == EmailSignInFormType.signIn ? EmailSignInFormType.register : EmailSignInFormType.signIn;
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
  void updateBirthday(String birthday) => updateWith(birthday: birthday);
  void updateCountry(String country) => updateWith(country: country);
  void updateCity(String city) => updateWith(city: city);
  void updateAddress(String address) => updateWith(address: address);
  void updatePhone(String phoneNumber) => updateWith(phoneNumber: phoneNumber);

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
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.fullName = fullName ?? this.fullName;
    this.birthday = birthday ?? this.birthday;
    this.country = country ?? this.country;
    this.city = city ?? this.city;
    this.address = address ?? this.address;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
