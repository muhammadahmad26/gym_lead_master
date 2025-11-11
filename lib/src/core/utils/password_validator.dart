class PasswordValidator {
  static bool isVail(String password) {
    String pattern = r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$';
    return RegExp(pattern).hasMatch(password);
  }

  static String? validator(String? password) {
    if (password == null || password.isEmpty) {
      return "Password is empty!";
    } else if (!isVail(password)) {
      return "Password must be at least 8 chars,(include 1 uppercase,1 number, 1 special char)";
    }
    return null;
  }
}
