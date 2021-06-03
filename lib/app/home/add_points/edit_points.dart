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
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class EditPoints extends StatefulWidget {
  const EditPoints({Key? key, this.database, this.point}) : super(key: key);

  final Database? database;
  final Point? point;

  static Future<void> show(BuildContext context, {Point? point}) async {
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

  int _currentValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Points'),
        actions: [
          TextButton(
            onPressed: () => _confirmSignOut(context),
            child: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 8),
            Text(
              "Select amount and tap button to scan",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberPicker(
                  value: _currentValue,
                  minValue: 0,
                  maxValue: 100,
                  onChanged: (value) => setState(() => _currentValue = value),
                  textStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white, fontSize: 42),
                ),
              ],
            ),
            CustomButton(
              color: Colors.white,
              child: Text("Scan to add"),
              width: 200,
              onPressed: () => scanToAdd(_currentValue),
            ),

            /*Row(
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
            ),*/
          ],
        ),
      ),
    );
  }

  Future<void> scanToAdd(int points) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);

      _addPoints(context, barcodeScanRes, points);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _addPoints(BuildContext context, String scannedId, int scannedPoints) async {
    String timestamp = DateTime.now().toIso8601String();
    final auth = Provider.of<AuthBase>(context, listen: false);
    final pointsToAdd = Point(points: scannedPoints, timestamp: timestamp, userId: scannedId);
    int totalPoints = await widget.database!.getUserDoc(scannedId).then((value) => value['totalPoints']);
    totalPoints = totalPoints + scannedPoints;
    try {
      await widget.database!.addPoints(pointsToAdd, scannedId, auth.currentUser!.displayName, timestamp);
      final totalPointsToAdd = Point(points: totalPoints, timestamp: timestamp, userId: scannedId);
      await widget.database!.editTotalUserPoints(totalPointsToAdd, scannedId);
      showAlertDialog(
        context,
        title: 'Success!',
        content: 'You have successfully added $scannedPoints points',
        defaultActionText: 'Ok',
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        showExceptionAlert(
          context,
          title: 'You don\'t have permissions for this action',
          exception: e,
        );
      } else {
        showAlertDialog(
          context,
          title: 'Error',
          content: 'There was an error adding points, please try again later',
          defaultActionText: 'Ok',
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
