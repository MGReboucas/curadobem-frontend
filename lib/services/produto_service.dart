import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class ProdutoService {
  static Future<List<Map<String, dynamic>>> getProdutos({
    String? busca,
    String? categoria,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{'page': '$page', 'limit': '$limit'};
      if (busca != null && busca.isNotEmpty) params['busca'] = busca;
      if (categoria != null && categoria.isNotEmpty) {
        params['categoria'] = categoria;
      }
      final response = await ApiService.get('/produtos', queryParams: params);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['itens'] is List) {
          return (data['itens'] as List).cast<Map<String, dynamic>>();
        }
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint('ProdutoService.getProdutos error: $e');
    }
    return [];
  }

  static Future<List<String>> getCategorias() async {
    try {
      final response = await ApiService.get('/categorias');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
    } catch (e) {
      debugPrint('ProdutoService.getCategorias error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getProduto(dynamic id) async {
    try {
      final response = await ApiService.get('/produtos/$id');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('ProdutoService.getProduto error: $e');
    }
    return null;
  }
}
