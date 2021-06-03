import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/helpers/reg_expressions.dart';
import 'package:ds_loyalty_user/app/home/add_points/edit_points.dart';
import 'package:ds_loyalty_user/app/home/models/point.dart';
import 'package:ds_loyalty_user/common_widgets/custom_button.dart';
import 'package:ds_loyalty_user/common_widgets/show_alert_dialog.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/common_widgets/show_qr_code.dart';
import 'package:ds_loyalty_user/services/api_paths.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'models/offer.dart';
import 'offers/edit_offer.dart';
import 'offers/list_items_builder.dart';
import 'offers/offer_list_tile.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

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
      title: 'Abmelden',
      content: 'Sind Sie sicher?',
      cancelActionText: 'Abbrechen',
      defaultActionText: 'Abmelden',
    );
    if (didRequestSignout == true) {
      _signOut(context);
    }
  }

  Future checkUserRole() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      final snapshot = await FirebaseFirestore.instance.collection(APIPath.admin()).doc(auth.currentUser!.uid).get();
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

  Future<void> _scanToRedeemPoints() async {
    String scannedId;
    final database = Provider.of<Database>(context, listen: false);
    String timestamp = DateTime.now().toIso8601String();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      scannedId = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Abbrechen", true, ScanMode.QR);

      RegExpMatch regexQR = RegExpressions.scannedQRegex.firstMatch(scannedId)!;
      String? userId = regexQR.group(1);
      int points = int.parse(regexQR.group(2)!);
      int totalPoints = await database.getUserDoc(userId).then((value) => value['totalPoints']);
      try {
        totalPoints = totalPoints - points;
        if (totalPoints < 0) {
          showAlertDialog(
            context,
            title: 'Nicht genug Punkte!',
            content: 'Der gescannte Benutzer hat nicht genug Punkte, um dieses Angebot zu nutzen.',
            defaultActionText: 'Ok',
          );
        } else {
          final totalPointsToRedeem = Point(points: totalPoints, timestamp: timestamp, userId: userId);
          await database.editTotalUserPoints(totalPointsToRedeem, userId);
          _redeemPoints(context, userId, points);
        }
      } on PlatformException catch (error) {
        print('$error');
      }
    } on PlatformException {
      scannedId = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _redeemPoints(BuildContext context, String? scannedId, int points) async {
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
          auth.currentUser!.displayName,
          timestamp);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        showExceptionAlert(
          context,
          title: 'You don\'t have these permissions',
          exception: e,
        );
      }
    }
  }

  Stream<DocumentSnapshot> provideDocumentFieldStream(currentUserId) {
    return FirebaseFirestore.instance.collection('users').doc('$currentUserId').snapshots();
  }

  /*String fullName;
  Function getName() {
    final auth = Provider.of<AuthBase>(context, listen: false);
    DocumentReference docRef = FirebaseFirestore.instance.collection("users").doc(auth.currentUser.uid);
    docRef.get().then((value) => fullName = value['fullName']);
    print(fullName);
  }*/

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    database.offersStream();

    if (isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Heim'),
          actions: [
            TextButton(
              onPressed: () => _confirmSignOut(context),
              child: Icon(
                Icons.logout,
                color: Colors.black,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildOffers(context),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  onPressed: () => EditOffer.show(context),
                  child: Row(
                    children: [
                      Text('Angebote'),
                      Icon(
                        Icons.add,
                        size: 22,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  child: Text('Einlösen'),
                  borderRadius: 0,
                  onPressed: _scanToRedeemPoints,
                ),
                CustomButton(
                  child: Text('Hinzufügen'),
                  borderRadius: 0,
                  onPressed: () => EditPoints.show(context),
                ),
              ],
            ),
            /*Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Redeem points',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      CustomButton(
                        child: Icon(Icons.remove_circle),
                        width: 120,
                        onPressed: () => _scanToRedeemPoints(),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Column(
                    children: [
                      Text(
                        'Add points',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      CustomButton(
                        child: Icon(Icons.add_circle),
                        width: 120,
                        onPressed: () => EditPoints.show(context),
                      ),
                    ],
                  )
                ],
              ),
            ),*/
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Heim'),
          actions: [
            TextButton(
              onPressed: () => _confirmSignOut(context),
              child: Icon(
                Icons.logout,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<DocumentSnapshot>(
                    stream: provideDocumentFieldStream(auth.currentUser!.uid),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        //snapshot -> AsyncSnapshot of DocumentSnapshot
                        //snapshot.data -> DocumentSnapshot
                        //snapshot.data.data -> Map of fields that you need :)
                        Map<String, dynamic> documentFields = snapshot.data!.data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  documentFields['fullName'].toString(),
                                  style: Theme.of(context).textTheme.overline,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Meine Punkte: ",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Text(
                                  documentFields['totalPoints'].toString(),
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            )
                          ],
                        );
                      } else {
                        return Text('Fehler...');
                      }
                    }),
                /*StreamBuilder<DocumentSnapshot>(
                    stream: provideDocumentFieldStream(auth.currentUser.uid),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        //snapshot -> AsyncSnapshot of DocumentSnapshot
                        //snapshot.data -> DocumentSnapshot
                        //snapshot.data.data -> Map of fields that you need :)
                        Map<String, dynamic> documentFields = snapshot.data.data();
                        return Text(
                          documentFields['totalPoints'].toString(),
                          style: Theme.of(context).textTheme.subtitle2,
                        );
                      } else {
                        return Text('Error...');
                      }
                    }),*/
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImage(
                  data: auth.currentUser!.uid,
                  version: QrVersions.auto,
                  size: 200,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
            Expanded(
              child: _buildOffers(context),
            )
          ],
        ),
      );
    }
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

  Future<void> _delete(BuildContext context, Offer job) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteOffer(job);
    } on FirebaseException catch (e) {
      showExceptionAlert(context, title: 'Operation failed', exception: e);
    }
  }

  _displayQRCard(BuildContext context, int? points, String? subtitle) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await showQRDialog(context, points: points, uid: auth.currentUser!.uid, subtitle: subtitle);
  }
}
