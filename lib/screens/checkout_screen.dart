import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/forma_pagamento.dart';
import '../services/carrinho_service.dart';
import 'confirmacao_pedido_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  final _formKey = GlobalKey<FormState>();

  // Endereço
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  bool _buscandoCep = false;

  // Pagamento
  FormaPagamento? _formaPagamento;
  final _nomeCartaoController = TextEditingController();
  final _numeroCartaoController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _processando = false;
  bool _resumoAberto = true;

  @override
  void dispose() {
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _nomeCartaoController.dispose();
    _numeroCartaoController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;
    setState(() => _buscandoCep = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _buscandoCep = false;
      _ruaController.text = 'Rua das Flores';
      _bairroController.text = 'Centro';
      _cidadeController.text = 'São Paulo';
      _estadoController.text = 'SP';
    });
  }

  Future<void> _fazerPedido() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_formaPagamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma forma de pagamento.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _processando = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _processando = false);

    final numeroPedido = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    final total = CarrinhoService.instancia.total;
    CarrinhoService.instancia.limpar();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ConfirmacaoPedidoScreen(
          numeroPedido: numeroPedido,
          total: total,
          formaPagamento: _formaPagamento!,
        ),
      ),
      (route) => route.isFirst,
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
                      'Carrinho',
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResumo(),
                      const SizedBox(height: 12),
                      _buildEndereco(),
                      const SizedBox(height: 12),
                      _buildPagamento(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            _buildRodape(),
          ],
        ),
      ),
    );
  }

  // ── Resumo ────────────────────────────────────────────────────────

  Widget _buildResumo() {
    final servico = CarrinhoService.instancia;
    return _buildCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _resumoAberto = !_resumoAberto),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Resumo do pedido', Icons.receipt_outlined),
                Icon(
                  _resumoAberto
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: verde,
                ),
              ],
            ),
          ),
          if (_resumoAberto) ...[
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: servico.itens,
              builder: (_, itens, __) => Column(
                children: itens
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantidade}x  ${item.produto['nome'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.tamanho != null) ...[
                              Text(
                                item.tamanho!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              item.produto['preco'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: verde,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Endereço ──────────────────────────────────────────────────────

  Widget _buildEndereco() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Endereço de entrega', Icons.location_on_outlined),
          const SizedBox(height: 14),

          // CEP
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCampo(
                  controller: _cepController,
                  label: 'CEP',
                  hint: '00000-000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'CEP inválido' : null,
                  onEditingComplete: _buscarCep,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _buscandoCep ? null : _buscarCep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: _buscandoCep
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _buildCampo(
            controller: _ruaController,
            label: 'Rua',
            hint: 'Nome da rua',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe a rua' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildCampo(
                  controller: _numeroController,
                  label: 'Número',
                  hint: '000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildCampo(
                  controller: _complementoController,
                  label: 'Complemento',
                  hint: 'Apto, bloco...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCampo(
            controller: _bairroController,
            label: 'Bairro',
            hint: 'Nome do bairro',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o bairro' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildCampo(
                  controller: _cidadeController,
                  label: 'Cidade',
                  hint: 'Sua cidade',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe a cidade'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildCampo(
                  controller: _estadoController,
                  label: 'UF',
                  hint: 'SP',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: (v) =>
                      (v == null || v.length < 2) ? 'Inválida' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Pagamento ─────────────────────────────────────────────────────

  Widget _buildPagamento() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Forma de pagamento', Icons.payment_outlined),
          const SizedBox(height: 12),
          _buildPaymentTile(
            label: 'PIX',
            subtitle: 'Pagamento instantâneo',
            icon: Icons.pix,
            value: FormaPagamento.pix,
          ),
          _buildPaymentTile(
            label: 'Cartão de Crédito',
            subtitle: 'À vista ou parcelado',
            icon: Icons.credit_card,
            value: FormaPagamento.cartaoCredito,
          ),
          _buildPaymentTile(
            label: 'Cartão de Débito',
            subtitle: 'Débito à vista',
            icon: Icons.payment,
            value: FormaPagamento.cartaoDebito,
          ),
          _buildPaymentTile(
            label: 'Boleto Bancário',
            subtitle: 'Vencimento em 3 dias úteis',
            icon: Icons.receipt_long,
            value: FormaPagamento.boleto,
          ),
          if (_formaPagamento == FormaPagamento.pix) _buildPix(),
          if (_formaPagamento == FormaPagamento.cartaoCredito ||
              _formaPagamento == FormaPagamento.cartaoDebito)
            _buildDetalhesCartao(),
          if (_formaPagamento == FormaPagamento.boleto) _buildBoleto(),
        ],
      ),
    );
  }

  Widget _buildPaymentTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required FormaPagamento value,
  }) {
    final selected = _formaPagamento == value;
    return GestureDetector(
      onTap: () => setState(() => _formaPagamento = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7EC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? verde : const Color(0xFFDDD8CC),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? verde : Colors.black45, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected ? verde : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? verde : Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPix() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF627348), width: 0.4),
      ),
      child: const Column(
        children: [
          Icon(Icons.pix, color: Color(0xFF627348), size: 48),
          SizedBox(height: 8),
          Text(
            'QR Code gerado após confirmar o pedido',
            style: TextStyle(
              color: Color(0xFF627348),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'O pagamento é confirmado em instantes',
            style: TextStyle(fontSize: 12, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBoleto() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDD8CC)),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long, color: Colors.black54, size: 48),
          SizedBox(height: 8),
          Text(
            'Boleto gerado após confirmar o pedido',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'Vencimento em 3 dias úteis',
            style: TextStyle(fontSize: 12, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetalhesCartao() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildCampo(
          controller: _nomeCartaoController,
          label: 'Nome no cartão',
          hint: 'Como aparece no cartão',
          textCapitalization: TextCapitalization.characters,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
        ),
        const SizedBox(height: 10),
        _buildCampo(
          controller: _numeroCartaoController,
          label: 'Número do cartão',
          hint: '0000 0000 0000 0000',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          validator: (v) {
            final digits = v?.replaceAll(' ', '') ?? '';
            return digits.length < 16 ? 'Número inválido' : null;
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCampo(
                controller: _validadeController,
                label: 'Validade',
                hint: 'MM/AA',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryFormatter(),
                ],
                validator: (v) =>
                    (v == null || v.length < 5) ? 'Inválida' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCampo(
                controller: _cvvController,
                label: 'CVV',
                hint: '000',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (v) =>
                    (v == null || v.length < 3) ? 'Inválido' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Rodapé ────────────────────────────────────────────────────────

  Widget _buildRodape() {
    return ValueListenableBuilder(
      valueListenable: CarrinhoService.instancia.itens,
      builder: (_, __, ___) {
        final totalFormatado =
            'R\$ ${CarrinhoService.instancia.total.toStringAsFixed(2).replaceAll('.', ',')}';
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _processando ? null : _fazerPedido,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 0,
                  ),
                  child: _processando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Fazer pedido',
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
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: verde, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: verde,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    VoidCallback? onEditingComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9F7F3),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDD8CC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDD8CC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF627348),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Formatters ────────────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length <= 2) return newValue.copyWith(text: digits);
    final result = '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
