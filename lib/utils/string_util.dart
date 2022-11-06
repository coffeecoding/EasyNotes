// courtesy https://stackoverflow.com/a/55768254
final alphaNumeric = RegExp(r'^[a-zA-Z0-9]+$');

extension AlphanumericTest on String {
  bool isAlphanumeric() => alphaNumeric.hasMatch(this);
}

extension EmailTest on String {
  bool isValidEmail() => RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(this);
}
