import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/home/models/offer.dart';
import 'package:ds_loyalty_user/app/home/models/point.dart';
import 'package:ds_loyalty_user/services/api_paths.dart';
import 'package:ds_loyalty_user/services/firestore_service.dart';

abstract class Database {
  Future<void> setOffer(Offer job);
  Future<void> addPoints(Point point, String? scannedId, String? admin, String timestamp);
  Future<void> editTotalUserPoints(Point point, String? scannedId);
  Stream<List<Offer>> offersStream();
  Future<void> deleteOffer(Offer job);
  Future<DocumentSnapshot> getUserDoc(String? scannedId);
  Stream<DocumentSnapshot> provideDocFieldStream(currentUserId);
  //Future<bool> checkUserRole(String userId, BuildContext context);
}

String documentTimestamp() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({required this.uid}) : assert(uid != null);

  final String uid;

  final _service = FirestoreService.instance;

  @override
  Future<void> addPoints(Point point, String? scannedId, String? adminName, String timestamp) => _service.setData(
        path: APIPath.point(scannedId, timestamp),
        data: point.pointToMap(scannedId, uid, adminName),
      );

  @override
  Future<void> editTotalUserPoints(Point point, String? scannedId) => _service.updateData(
        path: APIPath.user(scannedId),
        data: point.pointToMapDoc(scannedId),
      );

  @override
  Future<void> setOffer(Offer offer) => _service.setData(
        path: APIPath.offer(uid, offer.id),
        data: offer.offerToMap(),
      );

  @override
  Future<void> deleteOffer(Offer offer) => _service.deleteData(
        path: APIPath.offer(uid, offer.id),
      );

  @override
  Stream<List<Offer>> offersStream() => _service.collectionStream(
        path: APIPath.offers(uid),
        builder: (data, documentId) => Offer.fromMap(data, documentId),
      );

  @override
  Future<DocumentSnapshot> getUserDoc(String? scannedId) async {
    return await FirebaseFirestore.instance.doc(APIPath.user(scannedId)).get().then((value) => value);
  }

  @override
  Stream<DocumentSnapshot> provideDocFieldStream(currentUserId) {
    return FirebaseFirestore.instance.doc(APIPath.user('$currentUserId')).snapshots();
  }
}
