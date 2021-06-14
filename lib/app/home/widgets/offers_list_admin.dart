import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/home/models/offer.dart';
import 'package:ds_loyalty_user/app/home/offers/edit_offer.dart';
import 'package:ds_loyalty_user/app/home/offers/list_items_builder.dart';
import 'package:ds_loyalty_user/app/home/offers/offer_list_tile.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOffersList extends StatefulWidget {
  @override
  _AdminOffersListState createState() => _AdminOffersListState();
}

class _AdminOffersListState extends State<AdminOffersList> {
  Future<void> _delete(BuildContext context, Offer offer) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteOffer(offer);
    } on FirebaseException catch (e) {
      showExceptionAlert(context, title: 'Operation failed', exception: e);
    }
  }

  Widget build(BuildContext context) {
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
