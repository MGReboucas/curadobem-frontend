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
        // Salva o nome para exibição no header
        final usuario = data['usuario'];
        String nome = login; // fallback: o próprio login digitado
        if (usuario is Map<String, dynamic>) {
          nome =
              usuario['nome_completo']?.toString()?.trim() ??
              usuario['nome']?.toString()?.trim() ??
              usuario['username']?.toString()?.trim() ??
              login;
        }
        if (nome.isNotEmpty) await ApiService.saveNome(nome);
        final email = usuario?['email']?.toString()?.trim() ?? '';
        if (email.isNotEmpty) await ApiService.saveEmail(email);
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

  static Future<Map<String, dynamic>> solicitarRedefinicao(String email) async {
    try {
      final response = await ApiService.post('/auth/solicitar-redefinicao', {
        'email': email,
      }, auth: false);
      if (response.statusCode == 200) return {'sucesso': true};
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'sucesso': false,
        'mensagem': data['detail'] is String
            ? data['detail']
            : 'Erro ao enviar código.',
      };
    } catch (_) {
      return {
        'sucesso': false,
        'mensagem': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  static Future<Map<String, dynamic>> verificarCodigo(
    String email,
    String codigo,
  ) async {
    try {
      final response = await ApiService.post('/auth/verificar-codigo', {
        'email': email,
        'codigo': codigo,
      }, auth: false);
      if (response.statusCode == 200) return {'sucesso': true};
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'sucesso': false,
        'mensagem': data['detail'] is String
            ? data['detail']
            : 'Código inválido ou expirado.',
      };
    } catch (_) {
      return {
        'sucesso': false,
        'mensagem': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  static Future<Map<String, dynamic>> redefinirSenha(
    String email,
    String codigo,
    String novaSenha,
    String confirmaSenha,
  ) async {
    try {
      final response = await ApiService.post('/auth/redefinir-senha', {
        'email': email,
        'codigo': codigo,
        'nova_senha': novaSenha,
        'confirma_senha': confirmaSenha,
      }, auth: false);
      if (response.statusCode == 200) return {'sucesso': true};
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'sucesso': false,
        'mensagem': data['detail'] is String
            ? data['detail']
            : 'Erro ao redefinir senha.',
      };
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
