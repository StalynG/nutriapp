// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';

/// Servicio de autenticación con API backend
class AuthenticationService implements AuthenticationRepository {
  final String _baseUrl;
  final SharedPreferences _prefs;
  late http.Client _httpClient;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';

  AuthenticationService({
    required String baseUrl,
    required SharedPreferences prefs,
  })  : _baseUrl = baseUrl,
        _prefs = prefs {
    _httpClient = http.Client();
  }

  /// Obtiene los headers con el token de autenticación
  Future<Map<String, String>> _getHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token?.isValid ?? false) 'Authorization': '${token!.tokenType} ${token.accessToken}',
    };
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data['user']);
        final token = AuthToken.fromJson(data['token']);

        await _saveAuthToken(token);
        await _saveUser(user);

        return user;
      } else {
        throw HttpException('Error en registro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al registrarse: ${e.toString()}');
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data['user']);
        final token = AuthToken.fromJson(data['token']);

        await _saveAuthToken(token);
        await _saveUser(user);

        return user;
      } else {
        throw HttpException('Credenciales inválidas');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _httpClient.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
    } catch (e) {
      // Continuar aunque falle en backend
    } finally {
      await _clearAuthData();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<AuthToken?> getAuthToken() async {
    final tokenJson = _prefs.getString(_tokenKey);
    if (tokenJson != null) {
      return AuthToken.fromJson(jsonDecode(tokenJson) as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<AuthToken> refreshToken() async {
    try {
      final refreshToken = _prefs.getString(_refreshTokenKey);
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = AuthToken.fromJson(data['token']);
        await _saveAuthToken(newToken);
        return newToken;
      } else {
        throw HttpException('Error refreshing token');
      }
    } catch (e) {
      await _clearAuthData();
      throw Exception('Error al refrescar token: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token?.isValid ?? false;
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw HttpException('Error en reset de contraseña');
      }
    } catch (e) {
      throw Exception('Error al resetear contraseña: ${e.toString()}');
    }
  }

  @override
  Future<User> updateProfile({
    required String name,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$_baseUrl/user/profile'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'profile_image_url': profileImageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data);
        await _saveUser(user);
        return user;
      } else {
        throw HttpException('Error actualizando perfil');
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: ${e.toString()}');
    }
  }

  /// Guarda el token de autenticación
  Future<void> _saveAuthToken(AuthToken token) async {
    await _prefs.setString(_tokenKey, jsonEncode(token.toJson()));
    if (token.refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, token.refreshToken!);
    }
  }

  /// Guarda los datos del usuario
  Future<void> _saveUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Limpia datos de autenticación
  Future<void> _clearAuthData() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
  }
}
