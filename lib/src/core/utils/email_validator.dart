class EmailValidator {
  static bool isValid(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}$';
    return RegExp(pattern).hasMatch(email);
  }

  static String? validator(String? email) {
    if (email == null || email.isEmpty) {
      return "Email is empty.";
    } else if (!isValid(email)) {
      return "Enter a valid mail";
    }
    return null;
  }
}
