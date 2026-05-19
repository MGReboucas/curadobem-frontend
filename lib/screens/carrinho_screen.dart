import 'package:flutter/material.dart';
import '../models/carrinho_item.dart';
import '../services/carrinho_service.dart';

class CarrinhoScreen extends StatelessWidget {
  const CarrinhoScreen({super.key});

  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  @override
  Widget build(BuildContext context) {
    final servico = CarrinhoService.instancia;

    return Scaffold(
      backgroundColor: bege,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: verde,
                      size: 14,
                    ),
                    label: const Text(
                      'Voltar',
                      style: TextStyle(
                        color: verde,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: verde,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Spacer(),
                  Image.asset('assets/images/logo.png', height: 62),
                  const Spacer(),
                  const SizedBox(width: 60),
                ],
              ),
            ),

            Expanded(
              child: ValueListenableBuilder<List<CarrinhoItem>>(
                valueListenable: servico.itens,
                builder: (context, itens, _) {
                  if (itens.isEmpty) return _buildVazio(context);
                  return _buildLista(context, itens, servico);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVazio(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Color(0xFFCCC7B8),
          ),
          const SizedBox(height: 16),
          const Text(
            'Seu carrinho está vazio',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: verde,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text(
              'Continuar comprando',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(
    BuildContext context,
    List<CarrinhoItem> itens,
    CarrinhoService servico,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Row(
            children: [
              const Text(
                'Meu Carrinho',
                style: TextStyle(
                  color: verde,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: verde,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${servico.totalItens}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: itens.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildItemCard(context, itens[index], index, servico);
            },
          ),
        ),
        _buildRodape(context, servico),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    CarrinhoItem item,
    int index,
    CarrinhoService servico,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFFEEEEEE),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFFBBBBBB),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.produto['nome'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => servico.remover(index),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.tamanho != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tamanho: ${item.tamanho}',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
                if (item.cor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Cor: ${item.cor}',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Controles de quantidade
                    Row(
                      children: [
                        _botaoQtd(
                          Icons.remove,
                          () => servico.atualizarQuantidade(
                            index,
                            item.quantidade - 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '${item.quantidade}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: verde,
                            ),
                          ),
                        ),
                        _botaoQtd(
                          Icons.add,
                          () => servico.atualizarQuantidade(
                            index,
                            item.quantidade + 1,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.produto['preco'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: verde,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoQtd(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDE4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: verde, size: 14),
      ),
    );
  }

  Widget _buildRodape(BuildContext context, CarrinhoService servico) {
    final totalFormatado =
        'R\$ ${servico.total.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                totalFormatado,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: verde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Concluir compra',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
