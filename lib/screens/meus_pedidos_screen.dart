import 'package:flutter/material.dart';
import '../services/pedido_service.dart';

class MeusPedidosScreen extends StatefulWidget {
  const MeusPedidosScreen({super.key});

  @override
  State<MeusPedidosScreen> createState() => _MeusPedidosScreenState();
}

class _MeusPedidosScreenState extends State<MeusPedidosScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  List<Map<String, dynamic>> _pedidos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    final dados = await PedidoService.getMeusPedidos();
    if (!mounted) return;
    setState(() {
      _pedidos = dados;
      _carregando = false;
    });
  }

  String _formatarTotal(dynamic preco) {
    if (preco is num) {
      return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    return preco?.toString() ?? '';
  }

  String _formatarItens(dynamic itens) {
    if (itens is List) {
      final qtd = itens.length;
      return '$qtd ${qtd == 1 ? 'item' : 'itens'}';
    }
    return itens?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bege,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator(color: verde))
                  : _pedidos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum pedido encontrado.',
                        style: TextStyle(color: Colors.black45, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pedidos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _buildPedidoCard(_pedidos[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoCard(Map<String, dynamic> pedido) {
    final status =
        (pedido['status'] ?? pedido['estado'] ?? 'Pendente') as String;
    final statusColor = switch (status.toLowerCase()) {
      'entregue' => const Color(0xFF4CAF50),
      'em trânsito' || 'enviado' || 'a caminho' => const Color(0xFF2196F3),
      'cancelado' || 'cancelada' => Colors.redAccent,
      _ => Colors.orange,
    };
    final numero =
        pedido['id']?.toString() ?? pedido['numero']?.toString() ?? '-';
    final data = pedido['data'] ?? pedido['created_at'] ?? '';
    final totalStr = _formatarTotal(pedido['total'] ?? pedido['valor_total']);
    final itensStr = _formatarItens(pedido['itens'] ?? pedido['items']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido nº $numero',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEAE0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo(Icons.calendar_today_outlined, data.toString()),
              _buildInfo(Icons.inventory_2_outlined, itensStr),
              Text(
                totalStr,
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
    );
  }

  Widget _buildInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black38),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
    );
  }
}
