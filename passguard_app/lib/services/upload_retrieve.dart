import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart' as pc;

// Generates a 16-byte salt (for PBKDF2)
// Uint8List generateSalt() {
//   final secureRandom = pc.SecureRandom('Fortuna')
//     ..seed(pc.KeyParameter(Uint8List.fromList(List.generate(32, (i) => i)))); // Weak seed for example purposes
//   return secureRandom.nextBytes(16);
// }
Uint8List generateSalt([int length = 16]) {
  final secureRandom = Random.secure();
  final salt = Uint8List(length);
  for (int i = 0; i < length; i++) {
    salt[i] = secureRandom.nextInt(256); // 0-255
  }
  return salt;
}

// Derives a 256-bit key using PBKDF2 from a password and salt
enc.Key deriveKey(String password, Uint8List salt) {
  final keyParams = pc.Pbkdf2Parameters(salt, 10000, 32); // 100,000 iterations
  final generator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
    ..init(keyParams);
  final keyBytes = generator.process(utf8.encode(password));
  return enc.Key(Uint8List.fromList(keyBytes));
}

// Encrypts data with AES-CBC mode
String encrypt(String password, String plaintext) {
  final salt = generateSalt(); // Generate a random salt
  final key = deriveKey(password, salt); // Derive key from password
  final iv = enc.IV.fromLength(16); // Use a random IV (Initialization Vector)

  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(plaintext, iv: iv);

  // Store the salt and IV alongside the encrypted data (Base64 encoded)
  return base64Encode(salt + iv.bytes + encrypted.bytes);
}

void uploadPass(String encUsername, String encPass, String hostName, String accPass, [String? email]) async {
  String aesPass = encrypt(accPass, encPass);
  String uid = (FirebaseAuth.instance.currentUser?.uid ?? 'nullUser');
  if (uid != 'nullUser'){
    FirebaseFirestore.instance.collection("users").doc(uid).collection("accounts").doc(hostName).set({
      'username': encUsername,
      'password': aesPass,      
      'email': email ?? '', // Optional email

    });
  }
  
}



// Decrypts data using the same password
String decrypt(String password, String encryptedData) {
  final decoded = base64Decode(encryptedData);

  // Extract salt, IV, and ciphertext
  final salt = Uint8List.fromList(decoded.sublist(0, 16));
  final iv = enc.IV(Uint8List.fromList(decoded.sublist(16, 32)));
  final ciphertext = enc.Encrypted(Uint8List.fromList(decoded.sublist(32)));

  // Derive the key using the extracted salt
  final key = deriveKey(password, salt);

  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
  return encrypter.decrypt(ciphertext, iv: iv);
}

// // Decrypts data using the same password
// Future<String> decrypt(String password, String encryptedData) async {
//   final decoded = base64Decode(encryptedData);

//   // Extract salt, IV, and ciphertext
//   final salt = Uint8List.fromList(decoded.sublist(0, 16));
//   final iv = enc.IV(Uint8List.fromList(decoded.sublist(16, 32)));
//   final ciphertext = enc.Encrypted(Uint8List.fromList(decoded.sublist(32)));

//   // Derive the key using the extracted salt
//   final key = deriveKey(password, salt);

//   final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
//   return encrypter.decrypt(ciphertext, iv: iv);
// }

// Future<MapEntry<String, String>> retrievePass(String hostName) async {
//   String uid = (FirebaseAuth.instance.currentUser?.uid ?? 'nullUser');
//   if (uid != 'nullUser'){
//     DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection("users").doc(uid).collection("accounts").doc(hostName).get();
//     if (docSnap.exists){
//       Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
//       if(data != null){
//         return MapEntry(data['username'], data['password']);
//       }
//     }
//   }
//   return MapEntry('not found', 'not found');
// }

