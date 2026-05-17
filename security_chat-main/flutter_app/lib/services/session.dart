import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  Session._();
  static final Session instance = Session._();

  final _storage = const FlutterSecureStorage();

  String? token;
  int? userId;
  int? deviceId;
  String? role;

  String? deviceName;
  String? x25519PrivateKeyB64;
  String? x25519PublicKeyB64;
  String? ed25519PrivateKeyB64;
  String? ed25519PublicKeyB64;

  static const _kToken = 'token';
  static const _kUserId = 'userId';
  static const _kDeviceId = 'deviceId';
  static const _kRole = 'role';

  static const _kDeviceName = 'deviceName';
  static const _kXPriv = 'xPriv';
  static const _kXPub = 'xPub';
  static const _kEdPriv = 'edPriv';
  static const _kEdPub = 'edPub';

  static String _chatKeyStorageKey(int chatId) => 'chatKey_$chatId';

  Future<void> init() async {
    try {
      token = await _storage.read(key: _kToken);

      final userIdStr = await _storage.read(key: _kUserId);
      userId = userIdStr == null ? null : int.tryParse(userIdStr);

      final deviceIdStr = await _storage.read(key: _kDeviceId);
      deviceId = deviceIdStr == null ? null : int.tryParse(deviceIdStr);

      role = await _storage.read(key: _kRole);

      deviceName = await _storage.read(key: _kDeviceName);
      x25519PrivateKeyB64 = await _storage.read(key: _kXPriv);
      x25519PublicKeyB64 = await _storage.read(key: _kXPub);
      ed25519PrivateKeyB64 = await _storage.read(key: _kEdPriv);
      ed25519PublicKeyB64 = await _storage.read(key: _kEdPub);
    } catch (e) {
      print('SECURE STORAGE ERROR: $e');

      token = null;
      userId = null;
      deviceId = null;
      role = null;

      deviceName = null;
      x25519PrivateKeyB64 = null;
      x25519PublicKeyB64 = null;
      ed25519PrivateKeyB64 = null;
      ed25519PublicKeyB64 = null;
    }
  }

  bool get isAuthed => token != null && userId != null;

  bool get isAdmin => role == 'admin';

  bool get isManager => role == 'manager';

  bool get isEmployee => role == 'employee' || role == null;

  bool get canCreateGroupChats => role == 'admin' || role == 'manager';

  String get roleTitle {
    switch (role) {
      case 'admin':
        return 'Администратор';
      case 'manager':
        return 'Руководитель';
      case 'employee':
        return 'Сотрудник';
      default:
        return 'Сотрудник';
    }
  }

  bool get hasDeviceKeys =>
      x25519PrivateKeyB64 != null &&
      x25519PrivateKeyB64!.isNotEmpty &&
      x25519PublicKeyB64 != null &&
      x25519PublicKeyB64!.isNotEmpty &&
      ed25519PrivateKeyB64 != null &&
      ed25519PrivateKeyB64!.isNotEmpty &&
      ed25519PublicKeyB64 != null &&
      ed25519PublicKeyB64!.isNotEmpty;

  Future<void> saveAuth({
    required String token,
    required int userId,
    required String role,
  }) async {
    this.token = token;
    this.userId = userId;
    this.role = role;

    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUserId, value: userId.toString());
    await _storage.write(key: _kRole, value: role);
  }

  Future<void> saveDevice({
    required int deviceId,
    required String deviceName,
    required String xPriv,
    required String xPub,
    required String edPriv,
    required String edPub,
  }) async {
    this.deviceId = deviceId;
    this.deviceName = deviceName;
    x25519PrivateKeyB64 = xPriv;
    x25519PublicKeyB64 = xPub;
    ed25519PrivateKeyB64 = edPriv;
    ed25519PublicKeyB64 = edPub;

    await _storage.write(key: _kDeviceId, value: deviceId.toString());
    await _storage.write(key: _kDeviceName, value: deviceName);
    await _storage.write(key: _kXPriv, value: xPriv);
    await _storage.write(key: _kXPub, value: xPub);
    await _storage.write(key: _kEdPriv, value: edPriv);
    await _storage.write(key: _kEdPub, value: edPub);
  }

  Future<void> saveChatKey(int chatId, Uint8List key) async {
    await _storage.write(
      key: _chatKeyStorageKey(chatId),
      value: base64Encode(key),
    );
  }

  Future<Uint8List?> getChatKey(int chatId) async {
    final raw = await _storage.read(key: _chatKeyStorageKey(chatId));
    if (raw == null || raw.isEmpty) return null;

    try {
      return Uint8List.fromList(base64Decode(raw));
    } catch (e) {
      print('CHAT KEY DECODE ERROR: $e');
      return null;
    }
  }

  Future<void> deleteChatKey(int chatId) async {
    await _storage.delete(key: _chatKeyStorageKey(chatId));
  }

  Map<String, String> authHeaders() {
    if (token == null || token!.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<void> logout() async {
    token = null;
    userId = null;
    role = null;

    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kRole);
  }

  Future<void> wipeDevice() async {
    token = null;
    userId = null;
    deviceId = null;
    role = null;

    deviceName = null;
    x25519PrivateKeyB64 = null;
    x25519PublicKeyB64 = null;
    ed25519PrivateKeyB64 = null;
    ed25519PublicKeyB64 = null;

    await _storage.deleteAll();
  }
}