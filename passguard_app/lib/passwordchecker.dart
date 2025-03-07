import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

Future<bool> checkPasswordPwned(String password) async {
  // Hash the password using SHA-1\
  var bytes = utf8.encode(password); // Convert the password to bytes
  var sha1Hash = sha1.convert(bytes); // Create the SHA-1 hash

  String prefix = sha1Hash.toString().substring(0, 5); // Get the first 5 characters
  String suffix = sha1Hash.toString().substring(5); // Get the rest of the hash

  // Make a GET request to the API
  var url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    // The API returns a list of suffixes and counts
    String responseBody = response.body;

    // Check if the suffix exists in the response body
    var lines = responseBody.split('\n');
    for (var line in lines) {
      if (line.startsWith(suffix.toUpperCase())) {
        // If the suffix is found, it means the password has been pwned
        return true;
      }
    }

    // If the suffix is not found, the password has not been pwned
    return false;
  } else {
    throw Exception('Failed to check password');
  }
}
// firebase.ps1 cannot be loaded because running scripts is disabled
// WHY a\m i getting this error
// ChatGPT said:
// The error message you are encountering, "firebase.ps1 cannot be loaded because running scripts is disabled", is related to the PowerShell script execution policy on your system. By default, Windows PowerShell restricts the execution of scripts for security reasons. When you try to run a script like firebase.ps1, it's blocked due to these restrictions.

// You can resolve this issue by changing the execution policy in PowerShell. Here's how:

// Steps to fix it:
// Open PowerShell as Administrator:

// Press Win + X and select Windows PowerShell (Admin) or Command Prompt (Admin).
// Check the current execution policy:

// Type the following command and press Enter:
// powershell
// Copy
// Get-ExecutionPolicy
// This will return the current execution policy. Most likely, it will be set to Restricted.
// Change the execution policy:

// To allow scripts to run, type the following command and press Enter:
// powershell
// Copy
// Set-ExecutionPolicy RemoteSigned
// This allows locally created scripts to run but requires downloaded scripts to be signed by a trusted publisher.
// Confirm the change:

// When prompted, type Y to confirm the policy change.
// Verify the policy:

// To ensure the change was applied, you can check the execution policy again:
// powershell
// Copy
// Get-ExecutionPolicy
// It should now return RemoteSigned.

// Notes:
// The RemoteSigned policy allows local scripts to run but requires scripts downloaded from the internet to be signed by a trusted publisher.
// If you need to allow all scripts to run, you can use Set-ExecutionPolicy Unrestricted, but this is less secure and generally not recommended unless you're working in a trusted environment.
// After doing this, try running the Firebase script again, and the error should be resolved.

// Let me know if you run into any other issues!


// You said:
// use flutter to call the https://api.pwnedpasswords.com/range/password API and check if the password has been pwned
// ChatGPT said:
// To use Flutter to call the Pwned Password API (https://api.pwnedpasswords.com/range/password), you will need to make an HTTP request to the API to check whether the password has been exposed in a data breach.

// The Pwned Password API is based on a unique and secure way of checking passwords. Instead of sending the whole password, you send only the first 5 characters of the hashed password (SHA-1), and the API returns a list of suffixes that have been seen with those first 5 characters.

// Steps to call the API in Flutter:
// Add dependencies: Add the http package to your pubspec.yaml file to make HTTP requests:

// yaml
// Copy
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^0.13.3
// Then run flutter pub get to install the dependencies.

// Create a function to query the API:

// Here's a function that hashes the password, extracts the first 5 characters of the SHA-1 hash, and queries the API for pwned passwords:

// dart
// Copy
// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:crypto/crypto.dart';

// Future<bool> checkPasswordPwned(String password) async {
//   // Hash the password using SHA-1
//   var bytes = utf8.encode(password); // Convert the password to bytes
//   var sha1Hash = sha1.convert(bytes); // Create the SHA-1 hash

//   String prefix = sha1Hash.toString().substring(0, 5); // Get the first 5 characters
//   String suffix = sha1Hash.toString().substring(5); // Get the rest of the hash

//   // Make a GET request to the API
//   var url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
//   var response = await http.get(url);

//   if (response.statusCode == 200) {
//     // The API returns a list of suffixes and counts
//     String responseBody = response.body;

//     // Check if the suffix exists in the response body
//     var lines = responseBody.split('\n');
//     for (var line in lines) {
//       if (line.startsWith(suffix.toUpperCase())) {
//         // If the suffix is found, it means the password has been pwned
//         return true;
//       }
//     }

//     // If the suffix is not found, the password has not been pwned
//     return false;
//   } else {
//     throw Exception('Failed to check password');
//   }
// }
// Usage: You can call this function to check if a password has been pwned. Here's an example:

// dart
// Copy
// void main() async {
//   String password = 'password123'; // Enter the password to check
  
//   try {
//     bool isPwned = await checkPasswordPwned(password);
//     if (isPwned) {
//       print('This password has been pwned!');
//     } else {
//       print('This password has not been pwned.');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }
// Explanation:
// Hashing the password: The password is hashed using SHA-1 (which is supported by the crypto package in Dart).

// Making the API call: We send a GET request to https://api.pwnedpasswords.com/range/<prefix>, where <prefix> is the first 5 characters of the SHA-1 hash.

// Response Handling: The response from the API contains a list of suffixes that match the given prefix. We check if the password's suffix (the part of the hash after the first 5 characters) is in the list of suffixes. If it is, it means the password has been pwned.

// Important Notes:
// Security: The Pwned Password API does not return the full password hash, which ensures that your password remains secure. Only the hash's prefix is sent over the network.
// Rate Limiting: The API has rate limits, so if you are making a large number of requests in a short period, you may hit rate limits and should handle that appropriately.
// SHA-1 Hashing: The Pwned Password API uses SHA-1 hashing, so you should use the crypto package to generate the SHA-1 hash of the password.
// This setup will let you check if a password has been exposed in a known data breach using Flutter. Let me know if you need any further help!