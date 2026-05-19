import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProdutoScreen extends StatefulWidget {
  final Map<String, String> produto;

  const ProdutoScreen({super.key, required this.produto});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  String? _tamanhoSelecionado;
  int _quantidade = 1;

  final List<String> _tamanhos = ['P', 'M', 'G', 'GG'];

  final TextEditingController _cepController = TextEditingController();
  bool _calculandoFrete = false;
  List<Map<String, String>> _opcoesEntrega = [];
  String? _erroFrete;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _calcularFrete() async {
    final cep = _cepController.text.replaceAll('-', '').trim();
    if (cep.length != 8) {
      setState(() {
        _erroFrete = 'CEP inválido. Informe os 8 dígitos.';
        _opcoesEntrega = [];
      });
      return;
    }
    setState(() {
      _calculandoFrete = true;
      _erroFrete = null;
      _opcoesEntrega = [];
    });
    // Simulação de chamada à API de frete
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _calculandoFrete = false;
      _opcoesEntrega = [
        {'nome': 'PAC', 'prazo': '7 a 10 dias úteis', 'valor': 'R\$ 14,90'},
        {'nome': 'SEDEX', 'prazo': '2 a 4 dias úteis', 'valor': 'R\$ 28,50'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão voltar
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

                  // Logo centralizada
                  Image.asset('assets/images/logo.png', height: 62),

                  // Entrar/cadastrar
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (_) => false);
                    },
                    child: const Text(
                      'Entrar/cadastrar',
                      style: TextStyle(
                        color: verde,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: verde,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem do produto
                    Container(
                      width: double.infinity,
                      height: 320,
                      color: const Color(0xFFEEEEEE),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Color(0xFFBBBBBB),
                          size: 80,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome
                          Text(
                            produto['nome'] ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Preço
                          Text(
                            produto['preco'] ?? '',
                            style: const TextStyle(
                              color: verde,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const Divider(height: 28, color: Color(0xFFDDD8CC)),

                          // Descrição
                          const Text(
                            'Descrição',
                            style: TextStyle(
                              color: verde,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Blusa feminina de manga curta com tecido leve e confortável, ideal para o dia a dia. Disponível em diversas cores e tamanhos.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Tamanhos
                          const Text(
                            'Tamanho:',
                            style: TextStyle(
                              color: verde,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: _tamanhos.map((t) {
                              final sel = _tamanhoSelecionado == t;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _tamanhoSelecionado = t),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: sel ? verde : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: verde,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        color: sel ? Colors.white : verde,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 22),

                          // Quantidade
                          const Text(
                            'Quantidade:',
                            style: TextStyle(
                              color: verde,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _botaoQtd(Icons.remove, () {
                                if (_quantidade > 1) {
                                  setState(() => _quantidade--);
                                }
                              }),
                              const SizedBox(width: 20),
                              Text(
                                '$_quantidade',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: verde,
                                ),
                              ),
                              const SizedBox(width: 20),
                              _botaoQtd(
                                Icons.add,
                                () => setState(() => _quantidade++),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Divider(height: 1, color: Color(0xFFDDD8CC)),

                          const SizedBox(height: 20),

                          // Calcular Frete
                          const Text(
                            'Calcular Frete:',
                            style: TextStyle(
                              color: verde,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFDDD8CC),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _cepController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(8),
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Digite seu CEP',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _calculandoFrete
                                      ? null
                                      : _calcularFrete,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: verde,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: _calculandoFrete
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Calcular',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          if (_erroFrete != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _erroFrete!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ],

                          if (_opcoesEntrega.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ..._opcoesEntrega.map(
                              (op) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFDDD8CC),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          op['nome']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          op['prazo']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      op['valor']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: verde,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Botão adicionar ao carrinho
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: verde,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Adicionar ao carrinho',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Botão comprar agora
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: verde, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                'Comprar agora',
                                style: TextStyle(
                                  color: verde,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoQtd(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: verde, width: 1.5),
        ),
        child: Icon(icon, color: verde, size: 18),
      ),
    );
  }
}
