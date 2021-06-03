abstract class StringValidator {
  bool isValid(String? value);
}

class NonEmptyStringValidator implements StringValidator {
  @override
  bool isValid(String? value) {
    return value!.isNotEmpty;
  }
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = NonEmptyStringValidator();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final StringValidator nameValidator = NonEmptyStringValidator();
  final StringValidator birthdayValidator = NonEmptyStringValidator();
  final StringValidator countryValidator = NonEmptyStringValidator();
  final StringValidator cityValidator = NonEmptyStringValidator();
  final StringValidator addressValidator = NonEmptyStringValidator();
  final StringValidator phoneValidator = NonEmptyStringValidator();

  final String invalidEmailErrorText = 'Email field can\'t be empty';
  final String invalidPasswordErrorText = 'Password field can\'t be empty';
  final String invalidNameErrorText = 'Name field can\'t be empty';
  final String invalidBirthdayErrorText = 'Birthday field can\'t be empty';
  final String invalidCountryErrorText = 'Country field can\'t be empty';
  final String invalidCityErrorText = 'City field can\'t be empty';
  final String invalidAddressErrorText = 'Address field can\'t be empty';
  final String invalidPhoneErrorText = 'Phone field can\'t be empty';
}
