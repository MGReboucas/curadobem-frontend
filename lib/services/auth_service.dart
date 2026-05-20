import 'dart:convert';
import 'api_service.dart';

class AuthService {
  /// Faz login. Retorna {'sucesso': true} ou {'sucesso': false, 'mensagem': '...'}.
  static Future<Map<String, dynamic>> login(String login, String senha) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'login': login,
        'senha': senha,
      }, auth: false);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final token = data['access_token'] as String;
        await ApiService.saveToken(token);
        return {'sucesso': true, 'dados': data, 'usuario': data['usuario']};
      }
      final mensagem = data['detail'] is String
          ? data['detail']
          : 'Usuário ou senha inválidos.';
      return {'sucesso': false, 'mensagem': mensagem};
    } catch (_) {
      return {
        'sucesso': false,
        'mensagem': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  /// Cria uma nova conta.
  static Future<Map<String, dynamic>> register(
    String usuario,
    String email,
    String senha,
    String confirmaSenha,
  ) async {
    try {
      final response = await ApiService.post('/auth/cadastro', {
        'username': usuario,
        'email': email,
        'senha': senha,
        'confirma_senha': confirmaSenha,
      }, auth: false);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'sucesso': true};
      }
      final mensagem = data['detail'] is String
          ? data['detail']
          : 'Erro ao criar conta.';
      return {'sucesso': false, 'mensagem': mensagem};
    } catch (_) {
      return {
        'sucesso': false,
        'mensagem': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  static Future<Map<String, dynamic>> recuperarSenha(String email) async {
    try {
      final response = await ApiService.post('/auth/recuperar-senha', {
        'email': email,
      }, auth: false);
      if (response.statusCode == 200) {
        return {'sucesso': true};
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mensagem = data['detail'] is String
          ? data['detail']
          : 'Erro ao solicitar recuperação de senha.';
      return {'sucesso': false, 'mensagem': mensagem};
    } catch (_) {
      return {
        'sucesso': false,
        'mensagem': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}
