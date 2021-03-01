import 'package:flutter/foundation.dart';

class Point {
  Point({@required this.point, @required this.timestamp, @required this.userId});

  final int point;
  final int timestamp;
  final String userId;

  factory Point.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final int point = data['point'];
    final int timestamp = data['timestamp'];
    final String userId = data['userId'];

    return Point(
      point: point,
      timestamp: timestamp,
      userId: userId,
    );
  }

  Map<String, dynamic> pointToMap(String scannedId, String adminId, String adminName) {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'point': point,
      'timestamp': timestamp,
      'userId': scannedId,
    };
  }
}
