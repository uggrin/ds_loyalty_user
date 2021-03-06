import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/helpers/reg_expressions.dart';
import 'package:ds_loyalty_user/app/home/models/point.dart';
import 'package:ds_loyalty_user/common_widgets/show_alert_dialog.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/common_widgets/show_qr_code.dart';
import 'package:ds_loyalty_user/services/api_paths.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'add_points/edit_points.dart';
import 'models/offer.dart';
import 'offers/edit_offer.dart';
import 'offers/list_items_builder.dart';
import 'offers/offer_list_tile.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  // TODO: Connect feature
  Future<void> redeemPoints() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);

      RegExpMatch regexQR = RegExpressions.scannedQRegex.firstMatch(barcodeScanRes);
      String userId = regexQR.group(1);
      int points = int.parse(regexQR.group(2));

      _addPoint(context, userId, points);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _addPoint(BuildContext context, String scannedId, int points) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    String timestamp = DateTime.now().toIso8601String();
    try {
      await database.addPoints(
          Point(
            points: points,
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

  Future<bool> checkUserRole() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      final snapshot = await FirebaseFirestore.instance.collection(APIPath.admin()).doc(auth.currentUser.uid).get();
      this.setState(() {
        isAdmin = snapshot.exists;
      });
    } on FirebaseException catch (e) {
      showExceptionAlert(
        context,
        title: 'Error checking role',
        exception: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    database.offersStream();
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImage(
                  data: auth.currentUser.uid,
                  version: QrVersions.auto,
                  size: 250,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Max Musterman', style: Theme.of(context).textTheme.headline2),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  onPressed: () => EditOffer.show(context),
                  child: Icon(
                    Icons.add,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Expanded(
              child: _buildOffers(context),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EditPoints.show(context),
        //onPressed: () => scanQR(),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Offer job) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteOffer(job);
    } on FirebaseException catch (e) {
      showExceptionAlert(context, title: 'Operation failed', exception: e);
    }
  }

  _displayQRCard(BuildContext context, int points, String subtitle) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await showQRDialog(context, points: points, uid: auth.currentUser.uid, subtitle: subtitle);
  }

  Widget _buildOffers(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<List<Offer>>(
        stream: database.offersStream(),
        builder: (context, snapshot) {
          if (isAdmin) {
            return ListItemsBuilder<Offer>(
                snapshot: snapshot,
                itemBuilder: (context, offer) => Dismissible(
                      key: Key('offer-${offer.id}'),
                      background: Container(color: Colors.red),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _delete(context, offer),
                      child: OfferListTile(
                        offer: offer,
                        onTap: () => EditOffer.show(context, offer: offer),
                      ),
                    ));
          } else {
            return ListItemsBuilder<Offer>(
                snapshot: snapshot,
                itemBuilder: (context, offer) => OfferListTile(
                      offer: offer,
                      onTap: () => _displayQRCard(context, offer.pointCost, offer.name),
                    ));
          }
        });
  }
}
