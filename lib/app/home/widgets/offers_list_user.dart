import 'package:ds_loyalty_user/app/home/models/offer.dart';
import 'package:ds_loyalty_user/app/home/offers/list_items_builder.dart';
import 'package:ds_loyalty_user/app/home/offers/offer_list_tile.dart';
import 'package:ds_loyalty_user/common_widgets/show_qr_code.dart';
import 'package:ds_loyalty_user/services/auth.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserOffersList extends StatefulWidget {
  @override
  _UserOffersListState createState() => _UserOffersListState();
}

class _UserOffersListState extends State<UserOffersList> {
  _displayQRCard(BuildContext context, int? points, String? subtitle) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await showQRDialog(context, points: points, uid: auth.currentUser!.uid, subtitle: subtitle);
  }

  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<List<Offer>>(
        stream: database.offersStream(),
        builder: (context, snapshot) {
          return ListItemsBuilder<Offer>(
              snapshot: snapshot,
              itemBuilder: (context, offer) => OfferListTile(
                    offer: offer,
                    onTap: () => _displayQRCard(context, offer.pointCost, offer.name),
                  ));
        });
  }
}
