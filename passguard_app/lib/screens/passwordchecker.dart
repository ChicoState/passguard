// lib/passwordchecker.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

//Simple class to check password leaks via HIBP (pwnedpasswords)
// using K-Anonymity search by SHA-1 prefix. 
// returns true if the password is found in the database, otherwise false.
class  PasswordChecker {
  static Future<bool> checkPasswordLeak(String password) async {
    try {
      // 1)compute SHA1 hash of the password
      final hashed = sha1.convert(utf8.encode(password)).toString().toUpperCase();
      final prefix = hashed.substring(0, 5);
      final suffix = hashed.substring(5);

      // 2)query the range endpoint
      final url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch from HIBP, status: ${response.statusCode}');
      }

      // 3)parse lines of the response to see if suffix is found
      final lines = response.body.split('\n');
      for (var line in lines) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final lineHash = parts[0];  
         //final countStr = parts[1];    
          if (lineHash == suffix) {
            //found the password suffix in the database -> password is leaked
            return true;
          }
        }
      }

      //not found if we get here
      return false;
    } catch (e) {
      rethrow; 
    }
  }
}
