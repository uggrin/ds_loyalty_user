import 'package:ds_loyalty_user/app/sign_in/email_sign_in_page.dart';
import 'package:ds_loyalty_user/app/sign_in/sign_in_bloc.dart';
import 'package:ds_loyalty_user/app/sign_in/sign_in_button.dart';
import 'package:ds_loyalty_user/app/sign_in/social_sign_in_button.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, @required this.bloc}) : super(key: key);
  final SignInBloc bloc;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<SignInBloc>(
      create: (_) => SignInBloc(auth: auth),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<SignInBloc>(
        builder: (_, bloc, __) => SignInPage(
          bloc: bloc,
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException && exception.code == 'ERROR_ABORTED_BY_USER') {
      return;
    }
    showExceptionAlert(
      context,
      title: 'Sign in failed',
      exception: exception,
    );
  }

  void _signInEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(),
      ),
    );
  }

  Future<void> _signInGoogle(BuildContext context) async {
    try {
      await bloc.signInGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInFacebook(BuildContext context) async {
    try {
      await bloc.signInFacebook();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  /*Future<void> _signInAnonimously(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      setState(() => _isLoading = true);
      await auth.signInAnonimously();
    } on Exception catch (e) {
      _showSignInError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Welcome To Dirty South Club'),
        elevation: 0,
      ),
      body: StreamBuilder<bool>(
          stream: bloc.isLoadingStream,
          initialData: false,
          builder: (context, snapshot) {
            return _buildContent(context, snapshot.data);
          }),
      backgroundColor: Colors.black54,
    );
  }

  Widget _buildContent(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            SizedBox(
              height: 50,
              child: _buildHeader(isLoading),
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
              height: 45,
              width: MediaQuery.of(context).size.width - 180,
              onPressed: isLoading ? null : () => _signInGoogle(context),
            ),
            SizedBox(height: 12),
            SocialSignInButton(
              text: 'Facebook',
              assetName: 'facebook-logo',
              textColor: Colors.white,
              color: Color(0xFF334D92),
              height: 50,
              width: MediaQuery.of(context).size.width - 180,
              onPressed: isLoading ? null : () => _signInFacebook(context),
            ),
            SizedBox(height: 12),
            SignInButton(
              text: 'Email',
              textColor: Colors.black87,
              color: Colors.amber,
              height: 50,
              width: MediaQuery.of(context).size.width - 180,
              onPressed: isLoading ? null : () => _signInEmail(context),
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
      ),
    );
  }

  Widget _buildHeader(bool isLoading) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Sign In',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
