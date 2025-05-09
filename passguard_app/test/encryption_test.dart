import 'package:test/test.dart';
import 'package:passguard_app/services/upload_retrieve.dart';
import 'dart:typed_data';

void main() {
  const password = 'mySecretPassword'; //master password
  const plaintext = 'SensitiveData123'; 

  test('generateSaltIV returns 32 bytes', () {
    final saltIv = generateSaltIV();
    expect(saltIv.length, equals(32));
  });

  test('deriveKey returns consistent key for same password and salt', () {
    final salt = generateSaltIV().sublist(0, 16);
    final key1 = deriveKey(password, salt);
    final key2 = deriveKey(password, salt);
    expect(key1.base64, equals(key2.base64));
  });

  test('encrypt and decrypt restore original text', () {
    final saltIv = generateSaltIV();
    final salt = saltIv.sublist(0, 16);
    final iv = saltIv.sublist(16);
    final key = deriveKey(password, salt);

    final encrypted = encrypt(password, plaintext, key, Uint8List.fromList(iv));
    final decrypted = decrypt(password, encrypted, key, Uint8List.fromList(iv));

    expect(decrypted, equals(plaintext));
  });
}
