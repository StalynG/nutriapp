class AuthService {
  String? _token;

  bool get isAuthenticated => _token != null;

  Future<bool> login(String email, String password) async {
    // Simulación de llamada a backend
    await Future.delayed(const Duration(seconds: 1));

    // Token simulado
    _token = 'fake_jwt_token_123';
    return true;
  }

  void logout() {
    _token = null;
  }

  String? get token => _token;
}
