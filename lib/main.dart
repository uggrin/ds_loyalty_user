import 'package:ds_loyalty_user/app/landing_page.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:ds_loyalty_user/services/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DsApp());
}

class DsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: 'DS Loyalty',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          backgroundColor: Colors.black54,
        ),
        home: LandingPage(),
      ),
    );
  }
}
