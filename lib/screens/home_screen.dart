import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  final TextEditingController _searchController = TextEditingController();
  bool _filtrosAberto = false;

  final List<Map<String, String>> _novosProdutos = [
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
  ];

  final List<Map<String, String>> _outrosProdutos = [
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
    {'nome': 'Blusa feminina azul com...', 'preco': 'R\$ 99,90'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 62),
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

            // Conteúdo rolável
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Barra de pesquisa
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Pesquise seu look',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Filtros
                    GestureDetector(
                      onTap: () =>
                          setState(() => _filtrosAberto = !_filtrosAberto),
                      child: Row(
                        children: [
                          Icon(
                            _filtrosAberto
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: verde,
                            size: 20,
                          ),
                          const Text(
                            ' Filtros',
                            style: TextStyle(
                              color: verde,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_filtrosAberto) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Tamanho', 'Cor', 'Preço', 'Marca']
                            .map(
                              (f) => FilterChip(
                                label: Text(f),
                                selected: false,
                                onSelected: (_) {},
                                backgroundColor: Colors.white,
                                selectedColor: verde.withOpacity(0.2),
                                labelStyle: const TextStyle(color: verde),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Novos Produtos
                    _secaoTitulo('Novos Produtos:'),
                    const SizedBox(height: 10),
                    _gridProdutos(_novosProdutos),

                    const SizedBox(height: 20),

                    // Outros Produtos
                    _secaoTitulo('Outros Produtos:'),
                    const SizedBox(height: 10),
                    _gridProdutos(_outrosProdutos),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secaoTitulo(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        color: verde,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _gridProdutos(List<Map<String, String>> produtos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        final p = produtos[index];
        return _CardProduto(nome: p['nome']!, preco: p['preco']!);
      },
    );
  }
}

class _CardProduto extends StatelessWidget {
  final String nome;
  final String preco;

  const _CardProduto({required this.nome, required this.preco});

  static const Color verde = Color(0xFF627348);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do produto (placeholder)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFEEEEEE),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Color(0xFFBBBBBB),
                    size: 48,
                  ),
                ),
              ),
            ),
          ),

          // Nome e preço
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  preco,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: verde,
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
