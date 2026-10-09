/// Simple checks used to show the "verified" tick next to a field.
abstract final class InputValidators {
  /// Length of a UAE mobile number without the 971 country code.
  static const int uaeMobileNumberLength = 9;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Exactly 9 digits, e.g. 501234567.
  static bool isValidUaeMobileNumber(String value) =>
      value.length == uaeMobileNumberLength && RegExp(r'^\d+$').hasMatch(value);

  /// Something before and after an "@", with a dot in the domain,
  /// e.g. name@example.com.
  static bool isValidEmail(String value) =>
      _emailPattern.hasMatch(value.trim());
}
