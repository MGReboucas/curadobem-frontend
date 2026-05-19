import 'package:flutter/material.dart';
import '../models/carrinho_item.dart';
import '../services/carrinho_service.dart';
import 'carrinho_screen.dart';
import 'produto_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? usuario;

  const HomeScreen({super.key, this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  final TextEditingController _searchController = TextEditingController();
  bool _filtrosAberto = false;
  String? _categoriaSelecionada;

  final List<String> _categorias = [
    'Blusas',
    'Vestidos',
    'Calças',
    'Oculos',
    'Bijuteria',
  ];

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 62),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: CarrinhoService.instancia.itens,
                        builder: (context, itens, _) {
                          final total = itens.fold<int>(
                            0,
                            (s, i) => s + i.quantidade,
                          );
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CarrinhoScreen(),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: verde,
                                  size: 26,
                                ),
                              ),
                              if (total > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$total',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
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
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _filtrosAberto ? 'Fechar Filtro' : 'Filtros',
                            style: const TextStyle(
                              color: verde,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_filtrosAberto) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                            const Text(
                              'Escolha a categoria',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._categorias.map(
                              (cat) => GestureDetector(
                                onTap: () => setState(
                                  () => _categoriaSelecionada =
                                      _categoriaSelecionada == cat ? null : cat,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: verde,
                                      fontSize: 16,
                                      fontWeight: _categoriaSelecionada == cat
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      decorationColor: verde,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
        childAspectRatio: 0.60,
      ),
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        final p = produtos[index];
        return _CardProduto(produto: p);
      },
    );
  }
}

class _CardProduto extends StatelessWidget {
  final Map<String, String> produto;

  const _CardProduto({required this.produto});

  static const Color verde = Color(0xFF627348);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProdutoScreen(produto: produto)),
      ),
      child: Container(
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
                    produto['nome'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    produto['preco'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: verde,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {
                        CarrinhoService.instancia.adicionar(
                          CarrinhoItem(produto: produto),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Produto adicionado ao carrinho!'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verde,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Adicionar ao carrinho',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProdutoScreen(produto: produto),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: verde, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Comprar agora',
                        style: TextStyle(
                          color: verde,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
