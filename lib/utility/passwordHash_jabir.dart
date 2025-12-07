import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PasswordHashUtil {
  /// Hash a password using SHA256 algorithm with the project's secret key as salt
  static Future<String> hashPassword(String password) async {
    // Load the hash key from .env file
    await dotenv.load(fileName: ".env");
    String hashKey = dotenv.env['HASH_KEY'] ?? 'ProjectNASA_Poliwangi_-_7878HAShPassWordiaxcc';

    // Create salted password
    String saltedPassword = password + hashKey;

    // Hash using SHA256
    var bytes = utf8.encode(saltedPassword);
    var digest = sha256.convert(bytes);

    print('Hashing password: $password -> ${digest.toString()}'); // Debug log
    return digest.toString(); // Returns hex representation of the hash
  }

  /// Verify a password against its hash
  static Future<bool> verifyPassword(String password, String hash) async {
    try {
      // Recompute the hash using the same parameters and compare
      String computedHash = await hashPassword(password);
      print('Verifying: computed=$computedHash, stored=$hash, match=${computedHash == hash}'); // Debug log

      // Compare the computed hash with the stored hash
      return computedHash == hash;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }
}