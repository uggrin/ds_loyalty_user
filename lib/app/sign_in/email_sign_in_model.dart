import 'package:ds_loyalty_user/app/sign_in/validators.dart';

enum EmailSignInFormType { signIn, register }

class EmailSignInModel with EmailAndPasswordValidators {
  EmailSignInModel({
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

  final String email;
  final String password;
  final String? fullName;
  final String? birthday;
  final String? country;
  final String? city;
  final String? address;
  final String? phoneNumber;
  final EmailSignInFormType formType;
  final bool isLoading;
  final bool submitted;

  String get primaryButtonText {
    return formType == EmailSignInFormType.signIn ? 'Sign in' : 'Create an account';
  }

  String get secondaryButtonText {
    return formType == EmailSignInFormType.signIn ? 'Need an account? Register' : 'Have an account? Sign in';
  }

  bool get canSubmit {
    return emailValidator.isValid(email) &&
        passwordValidator.isValid(password) &&
        nameValidator.isValid(fullName) &&
        countryValidator.isValid(country) &&
        cityValidator.isValid(city) &&
        addressValidator.isValid(address) &&
        !isLoading;
  }

  String? get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String? get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  String? get nameErrorText {
    bool showErrorText = submitted && !nameValidator.isValid(fullName);
    return showErrorText ? invalidNameErrorText : null;
  }

  String? get countryErrorText {
    bool showErrorText = submitted && !countryValidator.isValid(country);
    return showErrorText ? invalidCountryErrorText : null;
  }

  String? get cityErrorText {
    bool showErrorText = submitted && !cityValidator.isValid(city);
    return showErrorText ? invalidCityErrorText : null;
  }

  String? get addressErrorText {
    bool showErrorText = submitted && !addressValidator.isValid(address);
    return showErrorText ? invalidAddressErrorText : null;
  }

  EmailSignInModel copyWith({
    String? email,
    String? password,
    String? fullName,
    String? birthday,
    String? country,
    String? city,
    String? address,
    String? phoneNumber,
    EmailSignInFormType? formType,
    bool? isLoading,
    bool? submitted,
  }) {
    return EmailSignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName,
      birthday: birthday,
      country: country,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
      formType: formType ?? this.formType,
      isLoading: isLoading ?? this.isLoading,
      submitted: submitted ?? this.submitted,
    );
  }
}
