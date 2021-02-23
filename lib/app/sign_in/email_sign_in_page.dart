import 'package:ds_loyalty_user/app/sign_in/email_sign_in_form_bloc_based.dart';
import 'package:flutter/material.dart';

class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sign In'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.grey[200],
            child: EmailSignInFormBloc.create(context),
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
