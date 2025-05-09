import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart' as pc;


//CREATE UNIT TESTING FOR THIS:
// Returns a [Uint8List] containing random bytes, each in the range 0–255.
Uint8List generateSaltIV([int length = 16]) {
  final secureRandom = Random.secure();
  final salt = Uint8List(length);
  for (int i = 0; i < length; i++) {
    salt[i] = secureRandom.nextInt(256); // 0-255
  }
  final iv = enc.IV.fromLength(16);
  return Uint8List.fromList(salt + iv.bytes);
}

// Derives a 256-bit key using PBKDF2 from a password and salt
enc.Key deriveKey(String password, Uint8List salt) {

  final keyParams = pc.Pbkdf2Parameters(salt, 10000, 16); // 100000 iterations, lower this number to speed up the encryption and decrpytion
  final generator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
    ..init(keyParams);
  final keyBytes = generator.process(utf8.encode(password));
  final result = enc.Key(Uint8List.fromList(keyBytes));
  return result;
}

// Encrypts data with AES-CBC mode
String encrypt(String password, String plaintext, enc.Key key, Uint8List iv) {
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
  
  final encrypted = encrypter.encrypt(plaintext, iv: enc.IV(iv));

  final result = base64Encode(encrypted.bytes);

  return result;
}

void uploadPass(String encUsername, String encPass, String hostName, String accPass, enc.Key key, Uint8List iv, [String? email]) async {

  String aesPass = encrypt(accPass, encPass, key, iv);
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
String decrypt(String password, String encryptedData, enc.Key key, Uint8List iv) { 
  final decoded = base64Decode(encryptedData);
  final ciphertext = enc.Encrypted(Uint8List.fromList(decoded));
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
  final ivy = enc.IV(iv);
  final result = encrypter.decrypt(ciphertext, iv: ivy);
  
 
  return result;
}
