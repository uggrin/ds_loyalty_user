import 'package:ds_loyalty_user/app/home/models/offer.dart';
import 'package:flutter/material.dart';

class OfferListTile extends StatelessWidget {
  const OfferListTile({Key? key, required this.offer, this.onTap}) : super(key: key);
  final Offer offer;

  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        offer.name!,
        style: TextStyle(color: Colors.grey[300], fontSize: 16),
      ),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.qr_code_scanner,
            color: Colors.grey[300],
            size: 16,
          ),
          SizedBox(width: 5),
          Text(
            offer.pointCost.toString(),
            style: TextStyle(fontSize: 18, color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }
}
