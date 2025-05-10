// test/password_checker_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:passguard_app/screens/passwordchecker.dart';
import 'package:passguard_app/services/upload_retrieve.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'dart:typed_data';
import 'mocks.mocks.dart';
import 'mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passguard_app/screens/home/home_screen.dart';

void main() {
  group('PasswordChecker', () {
    test('Detects a leaked password', () async {
      final result = await PasswordChecker.checkPasswordLeak('123456');
      expect(result, true); // assuming '123456' is known to be leaked
    });

    test('Returns false for a secure password', () async {
      final result = await PasswordChecker.checkPasswordLeak('randomSecure!@#');
      expect(result, false);
    });
  });
  group('Encryption Tests', () {
    test('Encrypt and decrypt returns original string', () {
      const password = 'myStrongPassword123!';
      const plaintext = 'SecretMessage123';

      // Generate salt + IV
      Uint8List saltAndIV = generateSaltIV();
      Uint8List salt = Uint8List.fromList(saltAndIV.sublist(0, 16));
      Uint8List iv = Uint8List.fromList(saltAndIV.sublist(16));

      // Derive key from password and salt
      enc.Key key = deriveKey(password, salt);

      // Encrypt
      String encrypted = encrypt(password, plaintext, key, iv);

      // Decrypt
      String decrypted = decrypt(password, encrypted, key, iv);

      // Assertion
      expect(decrypted, equals(plaintext));
    });

    test('Encrypted output is not same as plaintext', () {
      const password = 'myStrongPassword123!';
      const plaintext = 'AnotherSecret';

      Uint8List saltAndIV = generateSaltIV();
      Uint8List salt = Uint8List.fromList(saltAndIV.sublist(0, 16));
      Uint8List iv = Uint8List.fromList(saltAndIV.sublist(16));
      enc.Key key = deriveKey(password, salt);

      String encrypted = encrypt(password, plaintext, key, iv);

      expect(encrypted, isNot(equals(plaintext)));
    });
  });
  test('MockFirestore can set and get a document', () async {
    // Create the mocks with correct types
    final mockFirestore = MockFirebaseFirestore();
    final mockCollection = MockCollectionReference<Map<String, dynamic>>();
    final mockDoc = MockDocumentReference<Map<String, dynamic>>();
    final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // Set up the mock behavior
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('abc')).thenReturn(mockDoc);

    // Mock the set call (which returns Future<void>)
    when(mockDoc.set({'name': 'John'})).thenAnswer((_) async => null);

    // Mock the get call
    when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot['name']).thenReturn('John');

    // Act
    await mockFirestore.collection('users').doc('abc').set({'name': 'John'});
    final snapshot = await mockFirestore.collection('users').doc('abc').get();

    // Assert
    expect(snapshot['name'], 'John');
  });
}