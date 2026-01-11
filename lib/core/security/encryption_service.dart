import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:logging/logging.dart';

class EncryptionService {
  final _logger = Logger('EncryptionService');

  // FIXED KEY for application-wide backups (32 chars for AES-256)
  // In a real production environment with sync, this might be user-specific.
  // For local backups, this ensures the app can always restore its own backups.
  static const String _kKeyString = 'PosVentaSecureKey2026AES256Fixed';

  // IV size for AES is 16 bytes
  static const int _ivSize = 16;

  Future<void> encryptFile(File sourceFile, File outFile) async {
    try {
      final key = encrypt.Key.fromUtf8(_kKeyString);
      // Generate a random IV for each encryption
      final iv = encrypt.IV.fromLength(_ivSize);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final bytes = await sourceFile.readAsBytes();
      final encrypted = encrypter.encryptBytes(bytes, iv: iv);

      // We must prepend implementation details (IV) to the file to decrypt later
      // Format: [IV (16 bytes)] [Encrypted Data]
      final fileBytes = <int>[...iv.bytes, ...encrypted.bytes];

      await outFile.writeAsBytes(fileBytes);
    } catch (e, stack) {
      _logger.severe('Error encrypting file', e, stack);
      rethrow;
    }
  }

  Future<void> decryptFile(File sourceFile, File outFile) async {
    try {
      final key = encrypt.Key.fromUtf8(_kKeyString);

      final fileBytes = await sourceFile.readAsBytes();

      if (fileBytes.length < _ivSize) {
        throw Exception('Invalid backup file: Too short');
      }

      // Extract IV
      final ivBytes = fileBytes.sublist(0, _ivSize);
      final iv = encrypt.IV(ivBytes);

      // Extract Data
      final encryptedBytes = fileBytes.sublist(_ivSize);
      final encrypted = encrypt.Encrypted(encryptedBytes);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decryptedBytes = encrypter.decryptBytes(encrypted, iv: iv);

      await outFile.writeAsBytes(decryptedBytes);
    } catch (e, stack) {
      _logger.severe('Error decrypting file', e, stack);
      throw Exception(
        'Failed to decrypt backup. The file might be corrupted or from a different version.',
      );
    }
  }
}
