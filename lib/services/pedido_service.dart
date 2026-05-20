import 'dart:convert';
import '../models/carrinho_item.dart';
import '../models/forma_pagamento.dart';
import 'api_service.dart';

class PedidoService {
  static Future<Map<String, dynamic>> criarPedido({
    required List<CarrinhoItem> itens,
    required Map<String, String> endereco,
    required FormaPagamento formaPagamento,
  }) async {
    try {
      final body = {
        'itens': itens
            .map(
              (i) => {
                'produto_id': i.produto['id'],
                'nome': i.produto['nome'],
                'preco': i.produto['preco'],
                'tamanho': i.tamanho,
                'cor': i.cor,
                'quantidade': i.quantidade,
              },
            )
            .toList(),
        'endereco': endereco,
        'forma_pagamento': formaPagamento.name,
      };
      final response = await ApiService.post('/pedidos', body);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'sucesso': true, 'dados': data};
      }
      final mensagem = data['detail'] is String
          ? data['detail']
          : 'Erro ao criar pedido.';
      return {'sucesso': false, 'mensagem': mensagem};
    } catch (_) {
      return {
        'sucesso': false,
        'mensagem': 'Não foi possível conectar ao servidor.',
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getMeusPedidos() async {
    try {
      final response = await ApiService.get('/pedidos');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getPedido(dynamic id) async {
    try {
      final response = await ApiService.get('/pedidos/$id');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
