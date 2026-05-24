import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/carrinho_item.dart';
import '../services/api_service.dart';
import '../services/carrinho_service.dart';
import '../services/produto_service.dart';
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
  bool _carregando = true;
  String? _nomeUsuario;

  List<String> _categorias = [];

  List<Map<String, String>> _novosProdutos = [];
  List<Map<String, String>> _outrosProdutos = [];

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    _carregarCategorias();
    _carregarProdutos();
  }

  Future<void> _carregarUsuario() async {
    // Lê o nome salvo no login (resposta imediata)
    final nomeSalvo = await ApiService.getNome();
    if (!mounted) return;
    if (nomeSalvo != null && nomeSalvo.isNotEmpty) {
      setState(() => _nomeUsuario = nomeSalvo);
      return;
    }
    // Fallback: busca da API (caso não tenha no cache)
    final response = await ApiService.get('/usuario/perfil');
    if (!mounted) return;
    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      final data =
          (raw is Map<String, dynamic> &&
              raw.containsKey('usuario') &&
              raw['usuario'] is Map<String, dynamic>)
          ? raw['usuario'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      final nome =
          data['nome_completo']?.toString()?.trim() ??
          data['nome']?.toString()?.trim() ??
          data['username']?.toString()?.trim() ??
          data['email']?.toString()?.trim();
      if (nome != null && nome.isNotEmpty) {
        await ApiService.saveNome(nome);
        setState(() => _nomeUsuario = nome);
      }
    }
  }

  Future<void> _carregarCategorias() async {
    final cats = await ProdutoService.getCategorias();
    if (!mounted) return;
    setState(() => _categorias = cats);
  }

  Future<void> _carregarProdutos() async {
    setState(() => _carregando = true);
    final busca = _searchController.text.trim();
    final dados = await ProdutoService.getProdutos(
      busca: busca.isEmpty ? null : busca,
      categoria: _categoriaSelecionada,
    );
    if (!mounted) return;
    final todos = dados.map(_mapearProduto).toList();
    final metade = (todos.length / 2).ceil();
    setState(() {
      _novosProdutos = todos.take(metade).toList();
      _outrosProdutos = todos.skip(metade).toList();
      _carregando = false;
    });
  }

  Map<String, String> _mapearProduto(Map<String, dynamic> p) {
    String precoFormatado;
    if (p['preco_formatado'] != null) {
      precoFormatado = p['preco_formatado'].toString();
    } else {
      final preco = p['preco'];
      if (preco is num) {
        precoFormatado = 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
      } else {
        precoFormatado = preco?.toString() ?? '';
      }
    }
    return {
      'id': p['id']?.toString() ?? '',
      'nome': p['nome']?.toString() ?? '',
      'preco': precoFormatado,
      'descricao': p['descricao']?.toString() ?? '',
      'categoria': p['categoria']?.toString() ?? '',
      'imagem_url': p['imagem_url']?.toString() ?? '',
    };
  }

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
                      GestureDetector(
                        onTap: () {
                          if (_nomeUsuario != null) {
                            Navigator.of(context).pushNamed('/menu');
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  'Acesse sua conta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                                content: const Text(
                                  'Faça login ou cadastre-se para acessar seu perfil.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                actionsAlignment: MainAxisAlignment.center,
                                actionsPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                actions: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(
                                          context,
                                        ).pushNamedAndRemoveUntil(
                                          '/login',
                                          (_) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: verde,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Fazer login'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(
                                          context,
                                        ).pushNamedAndRemoveUntil(
                                          '/cadastro',
                                          (_) => false,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: verde,
                                        side: const BorderSide(color: verde),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Cadastrar'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_nomeUsuario != null) ...[
                                Text(
                                  'Olá, ${_nomeUsuario!.split(' ').first}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: verde,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              const Icon(
                                Icons.person_outline,
                                color: verde,
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                      ),
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
                        onSubmitted: (_) => _carregarProdutos(),
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
                                onTap: () {
                                  setState(
                                    () => _categoriaSelecionada =
                                        _categoriaSelecionada == cat
                                        ? null
                                        : cat,
                                  );
                                  _carregarProdutos();
                                },
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

                    // Banners
                    const _BannerCarousel(),

                    const SizedBox(height: 14),

                    // Novos Produtos
                    _secaoTitulo('Novos Produtos:'),
                    const SizedBox(height: 10),
                    if (_carregando)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: verde),
                        ),
                      )
                    else if (_novosProdutos.isEmpty && _outrosProdutos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Nenhum produto encontrado.',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                      )
                    else ...[
                      _gridProdutos(_novosProdutos),

                      const SizedBox(height: 20),

                      // Outros Produtos
                      if (_outrosProdutos.isNotEmpty) ...[
                        _secaoTitulo('Outros Produtos:'),
                        const SizedBox(height: 10),
                        _gridProdutos(_outrosProdutos),
                      ],
                    ],

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

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const _banners = [
    'assets/images/banners/banner-frete-gratis.png',
    'assets/images/banners/categorias.png',
    'assets/images/banners/cuppons-20-30-desconto.png',
  ];

  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _banners[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF627348)
                    : const Color(0xFF627348).withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
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
                      onPressed: () async {
                        final tamanho = await showModalBottomSheet<String>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (ctx) => Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selecione o tamanho',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: ['P', 'M', 'G', 'GG']
                                      .map(
                                        (t) => OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(t),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: verde,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            minimumSize: const Size(60, 48),
                                          ),
                                          child: Text(
                                            t,
                                            style: const TextStyle(
                                              color: verde,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (tamanho == null) return;
                        CarrinhoService.instancia.adicionar(
                          CarrinhoItem(produto: produto, tamanho: tamanho),
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
