import 'package:ds_loyalty_user/app/home/models/job.dart';
import 'package:ds_loyalty_user/app/home/models/point.dart';
import 'package:ds_loyalty_user/services/api_path.dart';
import 'package:ds_loyalty_user/services/firestore_service.dart';
import 'package:flutter/foundation.dart';

abstract class Database {
  Future<void> createJob(Job job);
  Future<void> addPoint(Point point, String scannedId, String admin, int timestamp);
  Stream<List<Job>> jobsStream();
}

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);

  final String uid;

  final _service = FirestoreService.instance;

  Future<void> addPoint(Point point, String scannedId, String adminName, int timestamp) => _service.setData(
        path: APIPath.point(scannedId, timestamp),
        data: point.pointToMap(scannedId, uid, adminName),
      );

  Future<void> createJob(Job job) => _service.setData(
        path: APIPath.job(uid, 'job_3'),
        data: job.jobToMap(),
      );

  Stream<List<Job>> jobsStream() => _service.collectionStream(
        path: APIPath.jobs(uid),
        builder: (data) => Job.fromMap(data),
      );
}
