class Point {
  Point({required this.points, required this.timestamp, required this.userId});

  final int? points;
  final String? timestamp;
  final String? userId;

  factory Point.fromMap(Map<String, dynamic> data) {
    /*if (data == null) {
      return null;
    }*/
    final int? point = data['points'];
    final String? timestamp = data['timestamp'];
    final String? userId = data['userId'];

    return Point(
      points: point,
      timestamp: timestamp,
      userId: userId,
    );
  }

  Map<String, dynamic> pointToMap(String? scannedId, String adminId, String? adminName) {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'points': points,
      'timestamp': timestamp,
      'userId': scannedId,
    };
  }

  Map<String, dynamic> pointToMapDoc(String? scannedId) {
    return {
      'totalPoints': points,
    };
  }
}
