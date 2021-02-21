import 'package:ds_loyalty_user/app/sign_in/email_sign_in_page.dart';
import 'package:ds_loyalty_user/app/sign_in/sign_in_button.dart';
import 'package:ds_loyalty_user/app/sign_in/social_sign_in_button.dart';
import 'package:ds_loyalty_user/services/auth_provider.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  void _signInEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(),
      ),
    );
  }

  Future<void> _signInAnonimously(BuildContext context) async {
    final auth = AuthProvider.of(context);
    try {
      await auth.signInAnonimously();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _signInGoogle(BuildContext context) async {
    final auth = AuthProvider.of(context);
    try {
      await auth.signInGoogle();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _signInFacebook(BuildContext context) async {
    final auth = AuthProvider.of(context);
    try {
      await auth.signInFacebook();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Welcome To Dirty South Club'),
        elevation: 0,
      ),
      body: _buildContent(context),
      backgroundColor: Colors.black54,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Container(
                //color: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/logo-dark.png',
                    scale: 1.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Text(
            'Sign In',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 12.0),
          /*Divider(
            height: 30,
            thickness: 2,
            color: Colors.grey,
          ),*/
          SocialSignInButton(
            text: 'Google',
            assetName: 'google-logo',
            textColor: Colors.black87,
            color: Colors.white,
            height: 50,
            onPressed: () => _signInGoogle(context),
          ),
          SizedBox(height: 12),
          SocialSignInButton(
            text: 'Facebook',
            assetName: 'facebook-logo',
            textColor: Colors.white,
            color: Color(0xFF334D92),
            height: 50,
            onPressed: () => _signInFacebook(context),
          ),
          SizedBox(height: 12),
          SignInButton(
            text: 'Email',
            textColor: Colors.black87,
            color: Colors.amber,
            height: 50,
            onPressed: () => _signInEmail(context),
          ),
          /*SizedBox(height: 12),
          Text(
            'or',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          SignInButton(
            text: 'Anonymous',
            textColor: Colors.black87,
            color: Colors.lime,
            height: 50,
            onPressed: () => _signInAnonimously(context),
          ),*/
        ],
      ),
    );
  }
}
