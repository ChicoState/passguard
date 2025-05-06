import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart' as pc;


//CREATE UNIT TESTING FOR THIS:
// Returns a [Uint8List] containing random bytes, each in the range 0–255.
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

  final keyParams = pc.Pbkdf2Parameters(salt, 100000, 16); // 100000 iterations, lower this number to speed up the encryption and decrpytion
  final generator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
    ..init(keyParams);
  final keyBytes = generator.process(utf8.encode(password));
  final result = enc.Key(Uint8List.fromList(keyBytes));

  return result;
}

// Encrypts data with AES-CBC mode
String encrypt(String password, String plaintext) {
  DateTime start = DateTime.now();
  

  final salt = generateSalt(); // Generate a random salt
  DateTime end = DateTime.now();
  print('encrypt: generateSalt took ${end.difference(start).inMilliseconds} ms');

  start = DateTime.now();
  final key = deriveKey(password, salt); // Derive key from password
  end = DateTime.now();
  print('encrypt: derivekey took ${end.difference(start).inMilliseconds} ms');

  start = DateTime.now();
  final iv = enc.IV.fromLength(16); // Use a random IV (Initialization Vector)
  end = DateTime.now();
  print('encrypt: random iv took ${end.difference(start).inMilliseconds} ms');

  start = DateTime.now();
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
  end = DateTime.now();
  print('encrypt: encrypter took ${end.difference(start).inMilliseconds} ms');
  
  start = DateTime.now();
  final encrypted = encrypter.encrypt(plaintext, iv: iv);
  end = DateTime.now();
  print('encrypt: encryption took ${end.difference(start).inMilliseconds} ms');

  start = DateTime.now();
  final result = base64Encode(salt + iv.bytes + encrypted.bytes);
  end = DateTime.now();
  print('encrypt: encoding took ${end.difference(start).inMilliseconds} ms');

  return result;
}

void uploadPass(String encUsername, String encPass, String hostName, String accPass, [String? email]) async {

  String aesPass = encrypt(accPass, encPass);
  String uid = (FirebaseAuth.instance.currentUser?.uid ?? 'nullUser');
  if (uid != 'nullUser'){
    await FirebaseFirestore.instance.collection("users").doc(uid).collection("accounts").doc(hostName).set({
      'username': encUsername,
      'password': aesPass,
      'email': email ?? '', // Optional email
    });
  }

}

// Decrypts data using the same password
String decrypt(String password, String encryptedData) {
  DateTime start = DateTime.now();

  
  final decoded = base64Decode(encryptedData);
  DateTime end = DateTime.now();
  print('decrypt: decoding took ${end.difference(start).inMilliseconds} ms');
  start = DateTime.now();
  // Extract salt, IV, and ciphertext
  final salt = Uint8List.fromList(decoded.sublist(0, 16));
  end = DateTime.now();
  print('decrypt: salt from decoding took ${end.difference(start).inMilliseconds} ms');
  start = DateTime.now();

  final iv = enc.IV(Uint8List.fromList(decoded.sublist(16, 32)));
  end = DateTime.now();
  print('decrypt: iv from decoding took ${end.difference(start).inMilliseconds} ms');
  start = DateTime.now();

  final ciphertext = enc.Encrypted(Uint8List.fromList(decoded.sublist(32)));
  end = DateTime.now();
  print('decrpyt: ciphertext from decoding took ${end.difference(start).inMilliseconds} ms');
  start = DateTime.now();
  // Derive the key using the extracted salt
  final key = deriveKey(password, salt);
  end = DateTime.now();
  print('decrypt: derivekey took ${end.difference(start).inMilliseconds} ms');
  start = DateTime.now();

  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
  final result = encrypter.decrypt(ciphertext, iv: iv);
  end = DateTime.now();
  print('decrpytion took ${end.difference(start).inMilliseconds} ms');
  start = DateTime.now();

  
 
  return result;
}
