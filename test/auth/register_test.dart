import 'package:flutter_test/flutter_test.dart';
import '../../lib/utility/emailValidator_jabir.dart'; // Use relative import from test/auth/ to lib/utility/

void main() {
  group('EmailValidator Tests', () {
    test('should validate correct student email format', () {
      expect(EmailValidator.isValidStudentEmail('student123@student.univ.ac.id'), true);
      expect(EmailValidator.isValidStudentEmail('john.doe@student.univ.ac.id'), true);
      expect(EmailValidator.isValidStudentEmail('user_name@student.univ.ac.id'), true);
    });

    test('should reject invalid email formats', () {
      expect(EmailValidator.isValidStudentEmail('student@gmail.com'), false);
      expect(EmailValidator.isValidStudentEmail('student@univ.ac.id'), false);
      expect(EmailValidator.isValidStudentEmail('student@student.univ.com'), false);
      expect(EmailValidator.isValidStudentEmail('invalid-email'), false);
    });
  });

  group('RegistrationForm Tests', () {
    test('should validate valid registration data', () {
      var validData = RegistrationForm(
        email: 'test@student.univ.ac.id',
        username: 'testuser',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(validData.validate(), null); // Should be null (valid)
    });

    test('should reject invalid email in registration data', () {
      var invalidData = RegistrationForm(
        email: 'test@gmail.com', // Invalid email
        username: 'testuser',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(invalidData.validate(), isNotNull); // Should return error message
    });

    test('should reject non-matching passwords', () {
      var invalidData = RegistrationForm(
        email: 'test@student.univ.ac.id',
        username: 'testuser',
        password: 'password123',
        confirmPassword: 'different',
      );

      expect(invalidData.validate(), isNotNull); // Should return error message
    });

    test('should reject short username', () {
      var invalidData = RegistrationForm(
        email: 'test@student.univ.ac.id',
        username: 'ab', // Too short
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(invalidData.validate(), isNotNull); // Should return error message
    });
  });
}