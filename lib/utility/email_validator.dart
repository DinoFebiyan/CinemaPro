/// Utility class for email validation
class EmailValidator {
  /// Validates if an email is in the format required: @student.univ.ac.id
  static bool isValidStudentEmail(String email) {
    // Regex pattern to match emails ending with @student.univ.ac.id
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@student\.univ\.ac\.id$');
    return emailRegex.hasMatch(email);
  }
}

/// Data structure for registration form validation (for UI validation)
class RegistrationForm {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;

  RegistrationForm({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
  });

  /// Validates all registration form fields
  String? validate() {
    // Email validation
    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!EmailValidator.isValidStudentEmail(email)) {
      return 'Email must end with @student.univ.ac.id';
    }

    // Username validation
    if (username.isEmpty) {
      return 'Username is required';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    // Password validation
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Confirm password validation
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // All validations passed
  }
}