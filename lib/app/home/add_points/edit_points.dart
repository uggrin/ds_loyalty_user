import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/home/models/point.dart';
import 'package:ds_loyalty_user/common_widgets/custom_button.dart';
import 'package:ds_loyalty_user/common_widgets/show_alert_dialog.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

class EditPoints extends StatefulWidget {
  const EditPoints({Key key, this.database, this.point}) : super(key: key);

  final Database database;
  final Point point;

  static Future<void> show(BuildContext context, {Point point}) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditPoints(
        database: database,
        point: point,
      ),
      fullscreenDialog: true,
    ));
  }

  @override
  _EditPointsState createState() => _EditPointsState();
}

class _EditPointsState extends State<EditPoints> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Points'),
        actions: [
          FlatButton(
            onPressed: () => _confirmSignOut(context),
            child: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  child: Text('1'),
                  onPressed: () {
                    scanQR(1);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  child: Text('2'),
                  onPressed: () {
                    scanQR(2);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  child: Text('5'),
                  onPressed: () {
                    scanQR(5);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  child: Text('10'),
                  onPressed: () {
                    scanQR(10);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scanQR(int points) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);

      _addPoint(context, barcodeScanRes, points);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _addPoint(BuildContext context, String scannedId, int points) async {
    String timestamp = DateTime.now().toIso8601String();
    final auth = Provider.of<AuthBase>(context, listen: false);
    final point = Point(points: points, timestamp: timestamp, userId: scannedId);
    try {
      await widget.database.addPoints(point, scannedId, auth.currentUser.displayName, timestamp);
      await widget.database.editTotalUserPoints(point, scannedId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        showExceptionAlert(
          context,
          title: 'You don\'t have permissions for this action',
          exception: e,
        );
      }
    }
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
}
