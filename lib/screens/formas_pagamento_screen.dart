import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/forma_pagamento.dart';

class FormasPagamentoScreen extends StatefulWidget {
  const FormasPagamentoScreen({super.key});

  @override
  State<FormasPagamentoScreen> createState() => _FormasPagamentoScreenState();
}

class _FormasPagamentoScreenState extends State<FormasPagamentoScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);
  static const String _prefKey = 'forma_pagamento_preferida';

  FormaPagamento? _preferida;

  static const _metodos = [
    _MetodoPagamento(
      valor: FormaPagamento.pix,
      icon: Icons.pix,
      label: 'PIX',
      descricao: 'Pagamento instantâneo, 24h por dia',
      detalhe:
          'O QR Code é gerado automaticamente após a confirmação do pedido. '
          'O pagamento é confirmado em segundos, sem taxas adicionais.',
      tag: 'Sem acréscimos',
      tagColor: Color(0xFF4CAF50),
    ),
    _MetodoPagamento(
      valor: FormaPagamento.cartaoCredito,
      icon: Icons.credit_card,
      label: 'Cartão de Crédito',
      descricao: 'À vista ou parcelado em até 12x',
      detalhe:
          'Aceitamos as principais bandeiras: Visa, Mastercard, Elo e American Express. '
          'Parcelamento disponível conforme condições do produto.',
      tag: 'Parcelamento disponível',
      tagColor: Color(0xFF627348),
    ),
    _MetodoPagamento(
      valor: FormaPagamento.cartaoDebito,
      icon: Icons.payment,
      label: 'Cartão de Débito',
      descricao: 'Débito à vista, aprovação imediata',
      detalhe:
          'Aceitamos Visa Débito, Mastercard Débito e Elo Débito. '
          'O valor é debitado diretamente da sua conta corrente.',
      tag: 'Sem acréscimos',
      tagColor: Color(0xFF4CAF50),
    ),
    _MetodoPagamento(
      valor: FormaPagamento.boleto,
      icon: Icons.receipt_long,
      label: 'Boleto Bancário',
      descricao: 'Vencimento em 3 dias úteis',
      detalhe:
          'O boleto é gerado após a confirmação do pedido. '
          'O pedido é processado somente após a confirmação do pagamento, '
          'que pode levar até 3 dias úteis.',
      tag: 'Prazo de 3 dias úteis',
      tagColor: Color(0xFFFF9800),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carregarPreferida();
  }

  Future<void> _carregarPreferida() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_prefKey);
    if (!mounted || salvo == null) return;
    setState(() {
      _preferida = FormaPagamento.values.firstWhere(
        (f) => f.name == salvo,
        orElse: () => FormaPagamento.pix,
      );
    });
  }

  Future<void> _salvarPreferida(FormaPagamento forma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, forma.name);
    if (!mounted) return;
    setState(() => _preferida = forma);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forma de pagamento preferida salva!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.payment_outlined,
                              color: verde,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Formas de Pagamento',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Defina sua forma preferida de pagamento',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Métodos
                    ..._metodos.map((m) => _buildCard(m)),

                    const SizedBox(height: 8),

                    // Nota
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7EC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: verde.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: verde, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A forma preferida será pré-selecionada automaticamente na tela de finalização de compra.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_MetodoPagamento m) {
    final preferida = _preferida == m.valor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: preferida
            ? Border.all(color: verde, width: 1.8)
            : Border.all(color: const Color(0xFFEEEBE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: preferida
                        ? const Color(0xFFEEF2E8)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    m.icon,
                    color: preferida ? verde : Colors.black45,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            m.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: preferida ? verde : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: m.tagColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              m.tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: m.tagColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.descricao,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _salvarPreferida(m.valor),
                  child: Icon(
                    preferida ? Icons.star_rounded : Icons.star_border_rounded,
                    color: preferida ? const Color(0xFFFFB300) : Colors.black26,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          // Detalhe expandido
          const Divider(height: 1, color: Color(0xFFEEEBE3)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.black38),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    m.detalhe,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetodoPagamento {
  final FormaPagamento valor;
  final IconData icon;
  final String label;
  final String descricao;
  final String detalhe;
  final String tag;
  final Color tagColor;

  const _MetodoPagamento({
    required this.valor,
    required this.icon,
    required this.label,
    required this.descricao,
    required this.detalhe,
    required this.tag,
    required this.tagColor,
  });
}
