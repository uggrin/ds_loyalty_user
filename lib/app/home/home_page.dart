import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/home/models/point.dart';
import 'package:ds_loyalty_user/common_widgets/show_alert_dialog.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  dynamic drawQR(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (auth.currentUser.uid.isNotEmpty) {
      return QrImage(
        data: auth.currentUser.uid,
        version: QrVersions.auto,
        size: 200,
        foregroundColor: Color.fromRGBO(255, 221, 51, 1),
      );
    } else {
      return Text('Error getting user');
    }
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);
      _addPoint(context, barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignout = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignout == true) {
      _signOut(context);
    }
  }

  // TODO: Add to users profile total points
  Future<void> _addPoint(BuildContext context, String scannedId) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.addPoint(
          Point(
            point: 1,
            timestamp: timestamp,
            userId: scannedId,
          ),
          scannedId,
          auth.currentUser.displayName,
          timestamp);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        showExceptionAlert(
          context,
          title: 'You don\'t have permissions',
          exception: e,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    database.jobsStream();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          FlatButton(
            onPressed: () => _confirmSignOut(context),
            child: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                drawQR(context),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total points: 4',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => scanQR(),
        child: Icon(Icons.add),
      ),
    );
  }
}
