import 'package:flutter/material.dart';
import '../models/forma_pagamento.dart';

class ConfirmacaoPedidoScreen extends StatelessWidget {
  final String numeroPedido;
  final double total;
  final FormaPagamento formaPagamento;

  const ConfirmacaoPedidoScreen({
    super.key,
    required this.numeroPedido,
    required this.total,
    required this.formaPagamento,
  });

  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  String get _labelPagamento {
    switch (formaPagamento) {
      case FormaPagamento.pix:
        return 'PIX';
      case FormaPagamento.cartaoCredito:
        return 'Cartão de Crédito';
      case FormaPagamento.cartaoDebito:
        return 'Cartão de Débito';
      case FormaPagamento.boleto:
        return 'Boleto Bancário';
    }
  }

  IconData get _iconePagamento {
    switch (formaPagamento) {
      case FormaPagamento.pix:
        return Icons.pix;
      case FormaPagamento.cartaoCredito:
      case FormaPagamento.cartaoDebito:
        return Icons.credit_card;
      case FormaPagamento.boleto:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFormatado =
        'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

    return Scaffold(
      backgroundColor: bege,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de sucesso
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F0E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: verde,
                    size: 56,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Pedido realizado!',
                  style: TextStyle(
                    color: verde,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Nº $numeroPedido',
                  style: const TextStyle(color: Colors.black45, fontSize: 14),
                ),

                const SizedBox(height: 32),

                // Card de resumo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        _iconePagamento,
                        'Forma de pagamento',
                        _labelPagamento,
                      ),
                      const Divider(height: 24, color: Color(0xFFEEEAE0)),
                      _buildInfoRow(
                        Icons.attach_money,
                        'Total pago',
                        totalFormatado,
                        valueStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: verde,
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFFEEEAE0)),
                      _buildInfoRow(
                        Icons.local_shipping_outlined,
                        'Status',
                        'Processando pedido',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Aviso de e-mail
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7EC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF627348),
                      width: 0.4,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mail_outline, color: verde, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Um e-mail com a confirmação e detalhes do pedido será enviado em breve.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (_) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Voltar para a loja',
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(icon, color: verde, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    valueStyle ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
