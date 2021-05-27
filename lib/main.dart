import 'package:ds_loyalty_user/app/landing_page.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/helpers/boja.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DsApp());
}

class DsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: MaterialApp(
        title: 'DS Loyalty',
        theme: ThemeData(
          primarySwatch: Boja.dsGoldPrimary,
          scaffoldBackgroundColor: Colors.black87,
          accentColor: Boja.dsaccent[400],
          fontFamily: 'Oswald',
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold, color: Boja.textondark),
            headline2: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Boja.textondark, fontStyle: FontStyle.italic),
            headline3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Boja.dsaccent[600], fontStyle: FontStyle.italic),
            headline6: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800, color: Boja.textondarkAccent, fontStyle: FontStyle.italic),
            bodyText1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, fontFamily: 'Oswald', color: Boja.textondarkAccent),
            bodyText2: TextStyle(fontSize: 14.0),
            overline: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w800, color: Boja.dsaccent[200], fontStyle: FontStyle.italic),
            subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: Boja.dsaccent[200], fontStyle: FontStyle.italic),
            subtitle2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, color: Boja.dsaccent[100], fontStyle: FontStyle.italic),
          ),
          primaryTextTheme: GoogleFonts.oswaldTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: LandingPage(),
      ),
    );
  }
}
