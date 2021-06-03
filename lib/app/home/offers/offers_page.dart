import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/home/offers/edit_offer.dart';
import 'package:ds_loyalty_user/app/home/offers/list_items_builder.dart';
import 'package:ds_loyalty_user/app/home/offers/offer_list_tile.dart';
import 'package:ds_loyalty_user/common_widgets/show_alert_dialog.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/offer.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({Key? key}) : super(key: key);

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

  Future<void> _delete(BuildContext context, Offer offer) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteOffer(offer);
    } on FirebaseException catch (e) {
      showExceptionAlert(context, title: 'Operation failed', exception: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    database.offersStream();
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Offers'),
        actions: [
          FlatButton(
            onPressed: () => _confirmSignOut(context),
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildContents(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EditOffer.show(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Offer>>(
        stream: database.offersStream(),
        builder: (context, snapshot) {
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
        });
  }
}
