import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String _serverUrl = 'http://127.0.0.1:8000';
  static const String _tokenKey = 'auth_token';
  static const String _nomeKey = 'user_nome';
  static const String _fotoKey = 'user_foto';

  /// Converte caminho relativo (/uploads/...) em URL absoluta.
  static String? resolverFotoUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '$_serverUrl$url';
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nomeKey);
  }

  static Future<void> saveNome(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nomeKey, nome);
  }

  static Future<void> clearNome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nomeKey);
  }

  static Future<String?> getFotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fotoKey);
  }

  static Future<void> saveFotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fotoKey, url);
  }

  static Future<void> clearFotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fotoKey);
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final headers = await _headers();
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) async {
    final headers = await _headers();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }

  static Future<http.Response> uploadFoto(
    Uint8List bytes,
    String filename,
  ) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/usuario/perfil/foto');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    final ext = filename.split('.').last.toLowerCase();
    final mime = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
        ? 'image/webp'
        : 'image/jpeg';
    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mime),
      ),
    );
    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }
}
