import 'dart:io';

import 'package:ds_loyalty_user/app/helpers/boja.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<bool?> showQRDialog(
  BuildContext context, {
  required int? points,
  required String? subtitle,
  required String uid,
}) {
  if (!Platform.isIOS) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                '$subtitle - $points points',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.width / 1.9,
                width: MediaQuery.of(context).size.width / 1.9,
                child: Center(
                  child: QrImage(
                    data: uid + '?$points',
                    version: QrVersions.auto,
                    size: 200,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop(true),
                  color: Colors.grey[400],
                ),
              ],
            ));
  }
  return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
            title: Text(points.toString()),
            content: QrImage(
              data: uid + '?points=$points',
              version: QrVersions.auto,
              size: 200,
              foregroundColor: Boja.dsaccent[50],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Close'),
              )
            ],
          ));
}
