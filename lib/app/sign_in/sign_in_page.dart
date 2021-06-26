import 'package:ds_loyalty_user/app/sign_in/email_sign_in_page.dart';
import 'package:ds_loyalty_user/app/sign_in/sign_in_manager.dart';
import 'package:ds_loyalty_user/app/sign_in/social_sign_in_button.dart';
import 'package:ds_loyalty_user/common_widgets/show_alert_dialog.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key, required this.manager, required this.isLoading})
      : super(key: key);
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

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException &&
        exception.code == 'ERROR_ABORTED_BY_USER') {
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
      await widget.manager.signInGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInFacebook(BuildContext context) async {
    try {
      await widget.manager.signInFacebook();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Willkommen im Dirty South Club!',
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
                      scale: 3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            SizedBox(
              height: 30,
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
              height: 35,
              width: MediaQuery.of(context).size.width - 180,
              onPressed: () => checkPrivacyAccept(1),
            ),
            SizedBox(height: 12),
            SocialSignInButton(
              text: 'Facebook',
              assetName: 'facebook-logo',
              textColor: Colors.white,
              color: Color(0xFF334D92),
              height: 40,
              width: MediaQuery.of(context).size.width - 180,
              onPressed: () => checkPrivacyAccept(2),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                policyBox(context),
                Expanded(
                  child: policyText(context),
                ),
              ],
            )
            /*SignInButton(
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

  bool? isChecked = false;

  @override
  Widget policyBox(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Color(0xFFFFDD33);
    }

    return Checkbox(
      checkColor: Colors.grey[900],
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value;
        });
      },
    );
  }

  Widget policyText(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 14),
        children: <TextSpan>[
          TextSpan(text: 'Um diese App zu nutzen, müssen Sie unsere '),
          TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchURL();
                }),
          TextSpan(text: ' akzeptieren.'),
        ],
      ),
    );
  }

  Future<void> _launchURL() async {
    const url = 'https://www.dirtysouth.at/privacy-policy-en/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  checkPrivacyAccept(int method) {
    if (!widget.isLoading && isChecked!) {
      if (method == 1) {
        _signInGoogle(context);
      } else {
        _signInFacebook(context);
      }
    } else {
      showAlertDialog(context,
          title: "Error",
          content:
              "Um diese App nutzen zu können, müssen Sie unsere Datenschutzrichtlinie akzeptieren",
          defaultActionText: "Ok");
    }
  }

  Widget _buildHeader() {
    if (widget.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Anmelden / Registrieren',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
