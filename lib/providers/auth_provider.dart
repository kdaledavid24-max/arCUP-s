import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

/// Authentication provider managing customer/admin sessions and credentials
class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _storage.getCurrentSession();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _storage.authenticateUser(email, password);
      if (user == null) {
        _errorMessage = 'Invalid email or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _storage.saveCurrentSession(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
    String role = 'customer',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _storage.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        address: address,
        role: role,
      );

      _currentUser = user;
      await _storage.saveCurrentSession(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.saveCurrentSession(null);
    notifyListeners();
  }

  Future<List<UserModel>> getAllUsers() async {
    return await _storage.getUsers();
  }
}
