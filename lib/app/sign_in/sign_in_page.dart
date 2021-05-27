import 'package:ds_loyalty_user/app/sign_in/email_sign_in_page.dart';
import 'package:ds_loyalty_user/app/sign_in/sign_in_manager.dart';
import 'package:ds_loyalty_user/app/sign_in/social_sign_in_button.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, @required this.manager, @required this.isLoading}) : super(key: key);
  final SignInManager manager;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, manager, __) => SignInPage(
              manager: manager,
              isLoading: isLoading.value,
            ),
          ),
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
      await manager.signInGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInFacebook(BuildContext context) async {
    try {
      await manager.signInFacebook();
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
        title: Text(
          'Welcome to Dirty South Club',
          style: GoogleFonts.oswald(
            fontSize: 26,
          ),
        ),
        elevation: 0,
        actions: [],
      ),
      body: _buildContent(context),
      backgroundColor: Colors.black54,
    );
  }

  Widget _buildContent(BuildContext context) {
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
              child: _buildHeader(),
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
            /*SizedBox(height: 12),
            SignInButton(
              text: 'Email',
              textColor: Colors.black87,
              color: Colors.amber,
              height: 50,
              width: MediaQuery.of(context).size.width - 180,
              onPressed: isLoading ? null : () => _signInEmail(context),
            ),*/
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

  Widget _buildHeader() {
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
