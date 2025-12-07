import 'dart:typed_data';
import 'package:argon2/argon2.dart';
import 'package:convert/convert.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PasswordHashUtil {
  /// Hash a password using Argon2 algorithm with the project's secret key
  static Future<String> hashPassword(String password) async {
    // Load the hash key from .env file
    await dotenv.load(fileName: ".env");
    String hashKey = dotenv.env['HASH_KEY'] ?? 'ProjectNASA_Poliwangi_-_7878HAShPassWordiaxcc';

    // Convert salt to bytes
    var salt = hashKey.substring(0, 16).codeUnits; // Use first 16 chars of hash key as salt

    var parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_i,  // Argon2i type
      salt,
      version: Argon2Parameters.ARGON2_VERSION_13, // Argon2 version 1.3
      iterations: 10,                       // Number of iterations
      memoryPowerOf2: 16,                   // 2^16 = 65536 bytes of memory
      lanes: 4,                            // Degree of parallelism
    );

    var argon2 = Argon2BytesGenerator();
    argon2.init(parameters);

    var passwordBytes = Uint8List.fromList(password.codeUnits);

    var result = Uint8List(32);  // Output hash length in bytes
    argon2.generateBytes(passwordBytes, result, 0, result.length);

    return result.toHexString();  // Returns hex representation of the hash
  }

  /// Verify a password against its hash
  static Future<bool> verifyPassword(String password, String hash) async {
    // Load the hash key from .env file
    await dotenv.load(fileName: ".env");
    String hashKey = dotenv.env['HASH_KEY'] ?? 'ProjectNASA_Poliwangi_-_7878HAShPassWordiaxcc';

    try {
      // Recompute the hash using the same parameters and compare
      String computedHash = await hashPassword(password);

      // Compare the computed hash with the stored hash
      return computedHash == hash;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }
}