class APIPath {
  static String job(String uid, String jobId) => 'users/$uid/jobs/$jobId';
  static String point(String scannedId, int timestamp) => 'users/$scannedId/points/$timestamp';
  static String jobs(String uid) => 'users/$uid/jobs';
  static String users() => 'users';
  static String user(String scannedId) => 'users/$scannedId';
}
