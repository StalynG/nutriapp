import 'auth_service.dart';

class AssistantAccessController {
  final AuthService authService;

  AssistantAccessController({required this.authService});

  bool canAccessAssistant() {
    return authService.isAuthenticated;
  }
}
