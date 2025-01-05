import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  static late final Key _key;
  static late final Encrypter _encrypter;

  static void initialize(String masterKey) {
    final keyBytes = Uint8List.fromList(masterKey.codeUnits);
    _key = Key(keyBytes);
    _encrypter = Encrypter(AES(_key));
  }

  static String encrypt(String text) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(text, iv: iv);
    return '${encrypted.base64}|${iv.base64}';
  }

  static String decrypt(String encrypted) {
    try {
      final parts = encrypted.split('|');
      final encryptedData = Encrypted.fromBase64(parts[0]);
      final iv = IV.fromBase64(parts[1]);
      return _encrypter.decrypt(encryptedData, iv: iv);
    } catch (e) {
      throw Exception('Gagal mendekripsi data');
    }
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  static bool verifyPassword(String password, String hash) {
    final hashedInput = hashPassword(password);
    return hashedInput == hash;
  }

  static String generateSalt() {
    final random = IV.fromSecureRandom(16);
    return base64.encode(random.bytes);
  }

  static String hashWithSalt(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }
}
