// ignore_for_file: public_member_api_docs

import '../entities/user.dart';

/// Contrato para el repositorio de autenticación
abstract class AuthenticationRepository {
  /// Registra un nuevo usuario
  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  /// Inicia sesión
  Future<User> login({
    required String email,
    required String password,
  });

  /// Cierra sesión
  Future<void> logout();

  /// Obtiene el usuario actual
  Future<User?> getCurrentUser();

  /// Obtiene el token actual
  Future<AuthToken?> getAuthToken();

  /// Refresca el token de autenticación
  Future<AuthToken> refreshToken();

  /// Verifica si el usuario está autenticado
  Future<bool> isAuthenticated();

  /// Recupera contraseña
  Future<void> resetPassword(String email);

  /// Actualiza el perfil de usuario
  Future<User> updateProfile({
    required String name,
    String? profileImageUrl,
  });
}
