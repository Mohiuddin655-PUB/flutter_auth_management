import 'dart:async' show StreamController;
import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:math' show Random;

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_entity/entity.dart' show Response, Status;

import '../models/auth.dart' show Auth;
import '../models/auth_mode.dart' show AuthMode;
import '../models/credential.dart' show Credential;
import 'backup.dart' show AuthBackupDelegate, BackupReader, BackupWriter;
import 'delegate.dart' show AuthDelegate;

/// Sign-in with no network or database: accounts live on the phone, through
/// [reader] and [writer] (the same storage the backup uses). Registering with
/// an email or a username and a password makes a uid as Firebase does (28
/// letters and digits); signing in again with them gives the same uid. The
/// password is kept only as a salted hash.
class OfflineAuthDelegate extends AuthDelegate {
  OfflineAuthDelegate({
    required this.reader,
    required this.writer,
    this.key = '__offline_auth__',
  });

  final BackupReader reader;
  final BackupWriter writer;
  final String key;

  _OfflineState? _state;

  @override
  AuthMode get mode => AuthMode.offline;

  @override
  bool get isAnonymous => _state?.anonymous ?? false;

  @override
  bool get isAuthenticated => _state?.current != null;

  @override
  Future<String?> get rawUid async => (await _load()).current;

  @override
  Future<bool> isSignIn() async => (await _load()).current != null;

  @override
  Future<Response<Credential>> signUpWithEmailNPassword(
    String email,
    String password,
  ) {
    return _signUp('email', email, password);
  }

  @override
  Future<Response<Credential>> signUpWithUsernameNPassword(
    String username,
    String password,
  ) {
    return _signUp('username', username, password);
  }

  @override
  Future<Response<Credential>> signInWithEmailNPassword(
    String email,
    String password,
  ) {
    return _signIn('email', email, password);
  }

  @override
  Future<Response<Credential>> signInWithUsernameNPassword(
    String username,
    String password,
  ) {
    return _signIn('username', username, password);
  }

  @override
  Future<Response<Credential>> signInAnonymously() async {
    final state = await _load();
    state.current ??= _uid();
    state.anonymous = true;
    await _save(state);
    return Response(status: Status.ok, data: Credential(uid: state.current));
  }

  @override
  Future<Response<void>> signOut() async {
    final state = await _load();
    state.current = null;
    state.anonymous = false;
    await _save(state);
    return Response(status: Status.ok);
  }

  /// Deletes the signed-in account from the phone.
  @override
  Future<Response<void>> delete() async {
    final state = await _load();
    final uid = state.current;
    if (uid == null) {
      return Response(status: Status.invalid, error: "User isn't valid!");
    }
    state.accounts.removeWhere((_, account) => account['uid'] == uid);
    state.current = null;
    state.anonymous = false;
    await _save(state);
    return Response(status: Status.ok);
  }

  Future<Response<Credential>> _signUp(
    String type,
    String id,
    String password,
  ) async {
    final name = _normalize(type, id);
    if (name.isEmpty || password.isEmpty) {
      return Response(
          status: Status.invalid, error: 'Enter your $type and password.');
    }
    final state = await _load();
    if (state.accounts.containsKey('$type:$name')) {
      return Response(
        status: Status.alreadyFound,
        error: 'An account with this $type already exists.',
      );
    }
    // A guest who registers keeps their uid, as Firebase links them.
    final uid =
        state.anonymous && state.current != null ? state.current! : _uid();
    final salt = _salt();
    state.accounts['$type:$name'] = {
      'uid': uid,
      type: name,
      'salt': salt,
      'hash': _hash(salt, password),
    };
    state.current = uid;
    state.anonymous = false;
    await _save(state);
    return Response(status: Status.ok, data: _credential(type, name, uid));
  }

  Future<Response<Credential>> _signIn(
    String type,
    String id,
    String password,
  ) async {
    final name = _normalize(type, id);
    final state = await _load();
    final account = state.accounts['$type:$name'];
    if (account == null) {
      return Response(
          status: Status.notFound, error: 'No account with this $type.');
    }
    if (_hash(account['salt'] as String, password) != account['hash']) {
      return Response(status: Status.invalid, error: 'Wrong password.');
    }
    final uid = account['uid'] as String;
    state.current = uid;
    state.anonymous = false;
    await _save(state);
    return Response(status: Status.ok, data: _credential(type, name, uid));
  }

  static Credential _credential(String type, String name, String uid) {
    return type == 'email'
        ? Credential(uid: uid, email: name)
        : Credential(uid: uid, displayName: name);
  }

  static String _normalize(String type, String value) {
    final trimmed = value.trim();
    return type == 'email' ? trimmed.toLowerCase() : trimmed;
  }

  static final _random = Random.secure();
  static const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  /// A uid shaped as Firebase's: 28 letters and digits.
  static String _uid() {
    return List.generate(28, (_) => _chars[_random.nextInt(_chars.length)])
        .join();
  }

  static String _salt() {
    return base64UrlNoPad(List.generate(16, (_) => _random.nextInt(256)));
  }

  /// A salted SHA-256, stretched so a copied store is slow to guess at.
  static String _hash(String salt, String password) {
    List<int> bytes = utf8.encode('$salt:$password');
    for (var i = 0; i < 10000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64UrlNoPad(bytes);
  }

  static String base64UrlNoPad(List<int> bytes) {
    const table =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    final out = StringBuffer();
    var buffer = 0, bits = 0;
    for (final b in bytes) {
      buffer = (buffer << 8) | b;
      bits += 8;
      while (bits >= 6) {
        bits -= 6;
        out.write(table[(buffer >> bits) & 63]);
      }
    }
    if (bits > 0) out.write(table[(buffer << (6 - bits)) & 63]);
    return out.toString();
  }

  Future<_OfflineState> _load() async {
    final cached = _state;
    if (cached != null) return cached;
    Map<String, dynamic> json = const {};
    try {
      final raw = await reader(key);
      if (raw != null && raw.isNotEmpty) {
        json = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      }
    } catch (_) {}
    return _state = _OfflineState.from(json);
  }

  Future<void> _save(_OfflineState state) async {
    _state = state;
    await writer(key, jsonEncode(state.json));
  }
}

class _OfflineState {
  _OfflineState(this.accounts, this.current, this.anonymous);

  factory _OfflineState.from(Map<String, dynamic> json) {
    final accounts = <String, Map<String, dynamic>>{};
    final raw = json['accounts'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is Map) accounts['$k'] = Map<String, dynamic>.from(v);
      });
    }
    return _OfflineState(
      accounts,
      json['current'] as String?,
      json['anonymous'] == true,
    );
  }

  final Map<String, Map<String, dynamic>> accounts;
  String? current;
  bool anonymous;

  Map<String, dynamic> get json => {
        'accounts': accounts,
        'current': current,
        'anonymous': anonymous,
      };
}

/// Keeps every user's data on the phone by uid, in place of a server: signing
/// in again brings back the same user with what was kept. Give it [build].
abstract class OfflineAuthBackupDelegate<T extends Auth>
    extends AuthBackupDelegate<T> {
  const OfflineAuthBackupDelegate({
    super.key,
    required super.reader,
    required super.writer,
    this.usersKey = '__offline_users__',
  });

  final String usersKey;

  static final _changes = StreamController<String>.broadcast();

  Future<Map<String, dynamic>> _users() async {
    try {
      final raw = await reader(usersKey);
      if (raw == null || raw.isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(Map<String, dynamic> users, String id) async {
    await writer(usersKey, jsonEncode(users));
    _changes.add(id);
  }

  @override
  Future<T?> onFetchUser(String id) async {
    final source = (await _users())[id];
    if (source is! Map) return null;
    return build(source);
  }

  @override
  Stream<T?> onListenUser(String id) {
    return _changes.stream.where((changed) => changed == id).asyncMap((_) {
      return onFetchUser(id);
    });
  }

  @override
  Future<void> onCreateUser(T data) async {
    final users = await _users();
    users[data.id] = data.filtered;
    await _write(users, data.id);
  }

  @override
  Future<void> onUpdateUser(
    String id,
    Map<String, dynamic> data,
    bool hasAnonymous,
  ) async {
    final users = await _users();
    final old = users[id] is Map
        ? Map<String, dynamic>.from(users[id] as Map)
        : <String, dynamic>{};
    final merged = {...old};
    data.forEach((key, value) {
      final parsed = nonEncodableObjectParser(value, old[key]);
      if (parsed == null) {
        merged.remove(key);
      } else {
        merged[key] = parsed;
      }
    });
    users[id] = merged;
    await _write(users, id);
  }

  @override
  Future<void> onDeleteUser(String id) async {
    final users = await _users();
    users.remove(id);
    await _write(users, id);
  }
}
