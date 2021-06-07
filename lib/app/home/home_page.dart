import 'dart:convert';

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
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
    checkUserVip();
    //_checkIfIsLogged();
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

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    database.offersStream();

    if (!isAdmin) {
      try {
        return _buildUserPage();
      } on Exception catch (e) {
        throw (e);
      }
    } else {
      try {
        return _buildAdminPage();
      } on Exception catch (e) {
        throw (e);
      }
    }
  }

  Widget _buildAdminPage() {
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
  }

  Widget _buildUserPage() {
    //final auth = Provider.of<AuthBase>(context, listen: false);

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
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfile(),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: _isVIP
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _toggle = !_toggle;
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(child: child, scale: animation);
                            },
                            child: _toggle ? _buildVIP() : _buildQr(),
                          ),
                        )
                      : _buildQr(),
                ),
              ],
            ),
          ),
          Expanded(child: _buildOffers(context)),
        ],
      ),
    );
  }

  Widget _buildQr() {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return QrImage(
      data: auth.currentUser!.uid,
      version: QrVersions.auto,
      size: 200,
      foregroundColor: Colors.white,
    );
  }

  Future checkUserVip() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      final snapshot = await FirebaseFirestore.instance.collection(APIPath.vip()).doc(auth.currentUser!.uid).get();
      this.setState(() {
        _isVIP = snapshot.exists;
      });
    } on FirebaseException catch (e) {
      showExceptionAlert(
        context,
        title: 'Error checking status',
        exception: e,
      );
    }
  }

  Widget _buildVIP() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset('assets/images/vip.png'),
    );
  }

  bool _isVIP = false;
  bool _toggle = false;
  void _toggleQR() {
    setState(() {
      if (_toggle) {
        _toggle = false;
      } else {
        _toggle = true;
      }
    });
  }

  //TODO: Revert strings.xml to live facebook app

  Widget _buildProfile() {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final Stream<DocumentSnapshot<Map<String, dynamic>>> _usersStream = FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Etwas ist schief gelaufen');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Warten...");
        }

        if (!snapshot.hasData) {
          return Text("Loading");
        }

        if (snapshot.hasError) {
          return Text('Error...');
        }

        if (snapshot.data!.exists) {
          Map<String, dynamic> documentFields = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentFields['fullName'],
                    style: Theme.of(context).textTheme.overline,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Meine Punkte: ",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    documentFields['totalPoints'].toString(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Text('There was an error...');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
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

  String prettyPrint(Map json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  bool _checking = true;
  Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _checking = false;
    });
    if (accessToken != null) {
      try {
        final userData = await FacebookAuth.instance.getUserData(fields: 'birthday,gender,location');
        print(accessToken.declinedPermissions);
      } on Exception catch (e) {}
    }
  }

  _displayQRCard(BuildContext context, int? points, String? subtitle) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await showQRDialog(context, points: points, uid: auth.currentUser!.uid, subtitle: subtitle);
  }
}
