import 'package:flutter/foundation.dart';
import '../models/carrinho_item.dart';

class CarrinhoService {
  CarrinhoService._();
  static final CarrinhoService instancia = CarrinhoService._();

  final ValueNotifier<List<CarrinhoItem>> itens =
      ValueNotifier<List<CarrinhoItem>>([]);

  void adicionar(CarrinhoItem novoItem) {
    final lista = List<CarrinhoItem>.from(itens.value);
    final idx = lista.indexWhere(
      (i) =>
          i.produto['nome'] == novoItem.produto['nome'] &&
          i.tamanho == novoItem.tamanho &&
          i.cor == novoItem.cor,
    );
    if (idx >= 0) {
      lista[idx].quantidade += novoItem.quantidade;
    } else {
      lista.add(novoItem);
    }
    itens.value = lista;
  }

  void remover(int index) {
    final lista = List<CarrinhoItem>.from(itens.value);
    lista.removeAt(index);
    itens.value = lista;
  }

  void atualizarQuantidade(int index, int quantidade) {
    final lista = List<CarrinhoItem>.from(itens.value);
    if (quantidade <= 0) {
      lista.removeAt(index);
    } else {
      lista[index].quantidade = quantidade;
    }
    itens.value = lista;
  }

  void limpar() => itens.value = [];

  int get totalItens =>
      itens.value.fold(0, (soma, item) => soma + item.quantidade);

  double get total {
    return itens.value.fold(0.0, (soma, item) {
      final precoStr = item.produto['preco'] ?? 'R\$ 0,00';
      final valor =
          double.tryParse(
            precoStr
                .replaceAll('R\$', '')
                .replaceAll(' ', '')
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) ??
          0.0;
      return soma + (valor * item.quantidade);
    });
  }
}
