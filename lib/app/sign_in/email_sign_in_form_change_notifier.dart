import 'package:ds_loyalty_user/app/sign_in/email_sign_in_model.dart';
import 'package:ds_loyalty_user/common_widgets/form_submit_button.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'email_sign_in_change_model.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  EmailSignInFormChangeNotifier({required this.model});
  final EmailSignInChangeModel model;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (_) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (_, model, __) => EmailSignInFormChangeNotifier(model: model),
      ),
    );
  }

  @override
  _EmailSignInFormChangeNotifierState createState() => _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState extends State<EmailSignInFormChangeNotifier> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _birthdayFocusNode = FocusNode();
  final FocusNode _countryFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  EmailSignInChangeModel get model => widget.model;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _birthdayController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _birthdayFocusNode.dispose();
    _countryFocusNode.dispose();
    _cityFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      showExceptionAlert(
        context,
        title: 'Sign in failed',
        exception: error,
      );
    }
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email) ? _passwordFocusNode : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _passwordEditingComplete() {
    final newFocus = model.passwordValidator.isValid(model.password) ? _nameFocusNode : _passwordFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _nameEditingComplete() {
    final newFocus = model.nameValidator.isValid(model.fullName) ? _birthdayFocusNode : _nameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _birthdayEditingComplete() {
    final newFocus = model.birthdayValidator.isValid(model.birthday) ? _countryFocusNode : _birthdayFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _countryEditingComplete() {
    final newFocus = model.countryValidator.isValid(model.country) ? _cityFocusNode : _countryFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _cityEditingComplete() {
    final newFocus = model.cityValidator.isValid(model.city) ? _addressFocusNode : _cityFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _addressEditingComplete() {
    final newFocus = model.addressValidator.isValid(model.address) ? _phoneFocusNode : _addressFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType() {
    model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _birthdayController.clear();
    _countryController.clear();
    _cityController.clear();
    _addressController.clear();
    _phoneController.clear();
  }

  List<Widget> _buildForm() {
    if (model.formType == EmailSignInFormType.signIn) {
      return [
        _buildEmailField(),
        SizedBox(height: 8.0),
        _buildPasswordField(),
        SizedBox(height: 8.0),
        FormSubmitButton(
          text: model.primaryButtonText,
          onPressed: model.canSignIn ? _submit : null,
        ),
        SizedBox(height: 8.0),
        FlatButton(
          onPressed: !model.isLoading ? _toggleFormType : null,
          child: Text(
            model.secondaryButtonText,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ];
    } else {
      return [
        _buildEmailField(),
        SizedBox(height: 8.0),
        _buildPasswordField(),
        SizedBox(height: 8.0),
        _buildNameField(),
        SizedBox(height: 8.0),
        _buildBirthdayField(),
        SizedBox(height: 8.0),
        _buildCountryField(),
        SizedBox(height: 8.0),
        _buildCityField(),
        SizedBox(height: 8.0),
        _buildAddressField(),
        SizedBox(height: 8.0),
        _buildPhoneField(),
        FormSubmitButton(
          text: model.primaryButtonText,
          onPressed: model.canRegister ? _submit : null,
        ),
        SizedBox(height: 8.0),
        FlatButton(
          onPressed: !model.isLoading ? _toggleFormType : null,
          child: Text(
            model.secondaryButtonText,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ];
    }
  }

  TextField _buildEmailField() {
    return TextField(
      focusNode: _emailFocusNode,
      controller: _emailController,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _emailEditingComplete(),
      onChanged: model.updateEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'address@mail.com',
        errorText: model.emailErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  TextField _buildPasswordField() {
    return TextField(
      focusNode: _passwordFocusNode,
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: model.passwordErrorText,
        enabled: model.isLoading == false,
      ),
      obscureText: true,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _passwordEditingComplete(),
      onChanged: model.updatePassword,
    );
  }

  TextField _buildNameField() {
    return TextField(
      focusNode: _nameFocusNode,
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Full Name',
        errorText: model.nameErrorText,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _nameEditingComplete(),
      onChanged: model.updateName,
    );
  }

  TextField _buildBirthdayField() {
    return TextField(
      focusNode: _birthdayFocusNode,
      controller: _birthdayController,
      decoration: InputDecoration(
        labelText: 'Birthday',
        errorText: model.birthdayErrorText,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _birthdayEditingComplete(),
      onChanged: model.updateBirthday,
    );
  }

  TextField _buildCountryField() {
    return TextField(
      focusNode: _countryFocusNode,
      controller: _countryController,
      decoration: InputDecoration(
        labelText: 'Country',
        errorText: model.countryErrorText,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _countryEditingComplete(),
      onChanged: model.updateCountry,
    );
  }

  TextField _buildCityField() {
    return TextField(
      focusNode: _cityFocusNode,
      controller: _cityController,
      decoration: InputDecoration(
        labelText: 'City',
        errorText: model.cityErrorText,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _cityEditingComplete(),
      onChanged: model.updateCity,
    );
  }

  TextField _buildAddressField() {
    return TextField(
      focusNode: _addressFocusNode,
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Address',
        errorText: model.addressErrorText,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _addressEditingComplete(),
      onChanged: model.updateAddress,
    );
  }

  TextField _buildPhoneField() {
    return TextField(
      focusNode: _phoneFocusNode,
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: '0677*********',
        errorText: model.phoneErrorText,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.done,
      onEditingComplete: _submit,
      onChanged: model.updatePhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _buildForm(),
        ),
      ),
    );
  }
}
