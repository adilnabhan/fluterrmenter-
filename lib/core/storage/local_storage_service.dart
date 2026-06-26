import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mentor_mobile_app/src/features/auth/login/domain/models/login_with_otp_model.dart';

/// 🔐 Secure local storage service using encrypted Hive
///
/// Security features:
/// - Encryption key stored in platform secure storage (Keychain/Keystore)
/// - Data encrypted at rest using AES-256
/// - Automatic key generation and management
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  static const String _boxName = 'secureAuthBox';
  static const String _userKey = 'user_data';
  static const String _encryptionKeyName = 'hive_encryption_key';

  late Box<String> _box;
  final _secureStorage = const FlutterSecureStorage();

  /// Initialize Hive with encryption
  Future<void> init() async {
    await Hive.initFlutter();

    // 🔑 Get or generate encryption key
    final encryptionKey = await _getEncryptionKey();

    // 📦 Open encrypted box
    _box = await Hive.openBox<String>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    print('✅ Secure Hive storage initialized with encryption');
  }

  /// Get existing encryption key or generate a new one
  /// Key is stored in platform secure storage (Keychain on iOS, Keystore on Android)
  Future<Uint8List> _getEncryptionKey() async {
    try {
      // Try to get existing key
      final existingKey = await _secureStorage.read(key: _encryptionKeyName);

      if (existingKey != null) {
        return Uint8List.fromList(base64Decode(existingKey));
      }

      // Generate new 256-bit key
      final newKey = Hive.generateSecureKey();
      final uint8Key = Uint8List.fromList(newKey);

      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Encode(uint8Key),
      );

      print('🔑 Generated new encryption key');
      return uint8Key;
    } catch (e) {
      print('❌ Error managing encryption key: $e');
      rethrow;
    }
  }

  /// Save user data (encrypted automatically)
  Future<void> saveUser(LoginSuccessModel user) async {
    try {
      await _box.put(_userKey, jsonEncode(user.toJson()));
      print('💾 User data saved securely');
    } catch (e) {
      print('❌ Error saving user to Hive: $e');
    }
  }

  /// Retrieve user data (decrypted automatically)
  LoginSuccessModel? getUser() {
    try {
      final userJson = _box.get(_userKey);
      if (userJson != null) {
        return LoginSuccessModel.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      print('❌ Error retrieving user from Hive: $e');
    }
    return null;
  }

  /// Clear user data
  Future<void> clearUser() async {
    try {
      await _box.delete(_userKey);
      print('🗑️ User data cleared');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }

  /// Clear all data and encryption key (use on logout or account deletion)
  Future<void> clearAll() async {
    try {
      await _box.clear();
      await _secureStorage.delete(key: _encryptionKeyName);
      print('🗑️ All secure data cleared');
    } catch (e) {
      print('❌ Error clearing all data: $e');
    }
  }
}
