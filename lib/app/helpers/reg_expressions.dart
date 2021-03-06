class RegExpressions {
  RegExpressions._();

  static RegExp scannedQRegex = new RegExp(
    r"(.*)\?(.*)",
    caseSensitive: false,
    multiLine: false,
  );
}
