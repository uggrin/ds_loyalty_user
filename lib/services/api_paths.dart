class APIPath {
  static String offer(String uid, String offerId) => 'offers/$offerId';
  static String offers(String uid) => 'offers/';
  static String point(String scannedId, String timestamp) => 'users/$scannedId/points/$timestamp';
  static String users() => 'users';
  static String user(String scannedId) => 'users/$scannedId';
  static String admin() => 'roles';
}
