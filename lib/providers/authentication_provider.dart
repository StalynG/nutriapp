// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../domain/entities/user.dart';
import '../domain/repositories/authentication_repository.dart';

enum AuthState { unauthenticated, loading, authenticated, error }

/// Provider que gestiona el estado de autenticación
class AuthenticationProvider extends ChangeNotifier {
  final AuthenticationRepository _repository;

  AuthState _state = AuthState.unauthenticated;
  String _error = '';
  User? _currentUser;
  bool _isEmailVerified = false;

  AuthenticationProvider(this._repository) {
    _initializeAuth();
  }

  // Getters
  AuthState get state => _state;
  String get error => _error;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isEmailVerified => _isEmailVerified;

  /// Inicializa el estado de autenticación
  Future<void> _initializeAuth() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        _currentUser = await _repository.getCurrentUser();
        _isEmailVerified = _currentUser?.isEmailVerified ?? false;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _error = 'Error inicializando autenticación: ${e.toString()}';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Registra un nuevo usuario
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _state = AuthState.loading;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _repository.register(
        email: email,
        password: password,
        name: name,
      );
      _isEmailVerified = _currentUser?.isEmailVerified ?? false;
      _state = AuthState.authenticated;
    } catch (e) {
      _error = 'Error en registro: ${e.toString()}';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Inicia sesión
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _repository.login(
        email: email,
        password: password,
      );
      _isEmailVerified = _currentUser?.isEmailVerified ?? false;
      _state = AuthState.authenticated;
    } catch (e) {
      _error = 'Error en login: ${e.toString()}';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Cierra sesión
  Future<void> logout() async {
    _state = AuthState.loading;
    _error = '';
    notifyListeners();

    try {
      await _repository.logout();
      _currentUser = null;
      _isEmailVerified = false;
      _state = AuthState.unauthenticated;
    } catch (e) {
      _error = 'Error al cerrar sesión: ${e.toString()}';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Recupera contraseña
  Future<void> resetPassword(String email) async {
    _state = AuthState.loading;
    _error = '';
    notifyListeners();

    try {
      await _repository.resetPassword(email);
      _state = AuthState.unauthenticated;
    } catch (e) {
      _error = 'Error en reset de contraseña: ${e.toString()}';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Actualiza el perfil del usuario
  Future<void> updateProfile({
    required String name,
    String? profileImageUrl,
  }) async {
    _state = AuthState.loading;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _repository.updateProfile(
        name: name,
        profileImageUrl: profileImageUrl,
      );
      _state = AuthState.authenticated;
    } catch (e) {
      _error = 'Error actualizando perfil: ${e.toString()}';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Limpia el estado de error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
