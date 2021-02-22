import 'package:ds_loyalty_user/app/landing_page.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          primarySwatch: Colors.amber,
          backgroundColor: Colors.black54,
        ),
        home: LandingPage(),
      ),
    );
  }
}
