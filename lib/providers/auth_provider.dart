import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  final _uuid = const Uuid();
  final _db = DatabaseHelper.instance;

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId == null) return;

    final userData = await _db.getUserById(userId);
    if (userData == null) return;

    final addresses = await _db.getAddresses(userId);

    _user = User(
      id: userData['id'] as String,
      email: userData['email'] as String,
      fullName: userData['full_name'] as String,
      phone: (userData['phone'] as String?) ?? '',
      avatarColor: (userData['avatar_color'] as int?) ?? User.avatarColors[0],
      addresses: addresses,
    );
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final existing = await _db.getUserByEmail(email);
    if (existing != null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final userId = _uuid.v4();
    final passwordHash = _hashPassword(password);

    final result = await _db.insertUser(
      id: userId,
      email: email,
      passwordHash: passwordHash,
      fullName: fullName,
      phone: phone,
    );

    if (result == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _user = User(
      id: userId,
      email: email.toLowerCase(),
      fullName: fullName,
      phone: phone,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final userData = await _db.getUserByEmail(email);
    if (userData == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final passwordHash = _hashPassword(password);
    if (userData['password_hash'] != passwordHash) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final userId = userData['id'] as String;
    final addresses = await _db.getAddresses(userId);

    _user = User(
      id: userId,
      email: userData['email'] as String,
      fullName: userData['full_name'] as String,
      phone: (userData['phone'] as String?) ?? '',
      avatarColor: (userData['avatar_color'] as int?) ?? User.avatarColors[0],
      addresses: addresses,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    int? avatarColor,
  }) async {
    if (_user == null) return;
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (avatarColor != null) data['avatar_color'] = avatarColor;

    await _db.updateUser(_user!.id, data);

    _user = _user!.copyWith(
      fullName: fullName,
      phone: phone,
      avatarColor: avatarColor,
    );
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    if (_user == null) return;
    final addresses = List<Address>.from(_user!.addresses);

    if (addresses.isEmpty) {
      final defaultAddr = address.copyWith(isDefault: true);
      await _db.insertAddress(_user!.id, defaultAddr);
      addresses.add(defaultAddr);
    } else {
      await _db.insertAddress(_user!.id, address);
      if (address.isDefault) {
        for (int i = 0; i < addresses.length; i++) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }
      addresses.add(address);
    }
    _user = _user!.copyWith(addresses: addresses);
    notifyListeners();
  }

  Future<void> updateAddress(Address address) async {
    if (_user == null) return;
    await _db.updateAddress(_user!.id, address);

    final addresses = List<Address>.from(_user!.addresses);
    if (address.isDefault) {
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }
    }
    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) addresses[index] = address;
    _user = _user!.copyWith(addresses: addresses);
    notifyListeners();
  }

  Future<void> removeAddress(String addressId) async {
    if (_user == null) return;
    await _db.deleteAddress(addressId);
    final addresses = _user!.addresses.where((a) => a.id != addressId).toList();
    _user = _user!.copyWith(addresses: addresses);
    notifyListeners();
  }

  Address? get defaultAddress {
    if (_user == null || _user!.addresses.isEmpty) return null;
    try {
      return _user!.addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _user!.addresses.first;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    notifyListeners();
  }
}
