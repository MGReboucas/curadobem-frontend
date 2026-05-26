import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/carrinho_item.dart';
import '../services/api_service.dart';
import '../services/carrinho_service.dart';
import 'carrinho_screen.dart';

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
  String? _nomeUsuario;

  final List<String> _tamanhos = ['P', 'M', 'G', 'GG'];

  final TextEditingController _cepController = TextEditingController();
  bool _calculandoFrete = false;
  List<Map<String, String>> _opcoesEntrega = [];
  String? _erroFrete;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final nome = await ApiService.getNome();
    if (!mounted) return;
    if (nome != null && nome.isNotEmpty) {
      setState(() => _nomeUsuario = nome);
    }
  }

  Future<void> _enviarDuvida(String pergunta) async {
    final response = await ApiService.post('/duvidas', {
      'produto_id': int.tryParse(widget.produto['id'] ?? ''),
      'produto_nome': widget.produto['nome'],
      'pergunta': pergunta,
    });
    if (!mounted) return;
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dúvida enviada! Responderemos em breve.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar dúvida. Tente novamente.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _abrirDialogDuvida(BuildContext context) async {
    if (!await _exigirLogin(context)) return;
    if (!context.mounted) return;
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Tire sua dúvida',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.produto['nome'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF627348),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Digite sua pergunta sobre o produto...',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                border: OutlineInputBorder(
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
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF627348),
                    side: const BorderSide(color: Color(0xFF627348)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final texto = controller.text.trim();
                    if (texto.isEmpty) return;
                    Navigator.of(ctx).pop();
                    _enviarDuvida(texto);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF627348),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<bool> _exigirLogin(BuildContext context) async {
    if (_nomeUsuario != null) return true;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Acesse sua conta',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Faça login ou cadastre-se para continuar.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (_) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF627348),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                ).pushNamedAndRemoveUntil('/cadastro', (_) => false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF627348),
                side: const BorderSide(color: Color(0xFF627348)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Criar conta'),
            ),
          ),
        ],
      ),
    );
    return false;
  }

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
    try {
      final response = await ApiService.post('/frete/calcular', {
        'cep_destino': cep,
        'itens': [
          {'produto_id': widget.produto['id'], 'quantidade': _quantidade},
        ],
      });
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> opcoesBruto;
        if (data is List) {
          opcoesBruto = data;
        } else if (data is Map && data['opcoes'] is List) {
          opcoesBruto = data['opcoes'] as List;
        } else {
          opcoesBruto = [];
        }
        setState(() {
          _calculandoFrete = false;
          _opcoesEntrega = opcoesBruto.map((o) {
            final m = o as Map<String, dynamic>;
            return {
              'nome': m['nome']?.toString() ?? m['servico']?.toString() ?? '',
              'prazo': m['prazo']?.toString() ?? '',
              'valor': m['valor']?.toString() ?? '',
            };
          }).toList();
        });
      } else {
        setState(() {
          _calculandoFrete = false;
          _erroFrete = 'Não foi possível calcular o frete.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _calculandoFrete = false;
          _erroFrete = 'Não foi possível calcular o frete.';
        });
      }
    }
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

                  // Usuário + Carrinho
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

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem do produto
                    () {
                      final rawUrl = produto['imagem_url'] ?? '';
                      final imageUrl = ApiService.resolverFotoUrl(
                        rawUrl.isNotEmpty ? rawUrl : null,
                      );
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        return SizedBox(
                          width: double.infinity,
                          height: 320,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: const Color(0xFFEEEEEE),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF627348),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFEEEEEE),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFFBBBBBB),
                                  size: 80,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Container(
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
                      );
                    }(),

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
                              onPressed: () async {
                                if (!await _exigirLogin(context)) return;
                                if (!context.mounted) return;
                                if (_tamanhoSelecionado == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Selecione o tamanho antes de continuar.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                CarrinhoService.instancia.adicionar(
                                  CarrinhoItem(
                                    produto: produto,
                                    tamanho: _tamanhoSelecionado,
                                    quantidade: _quantidade,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Produto adicionado ao carrinho!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'Ver carrinho',
                                      textColor: Colors.white,
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CarrinhoScreen(),
                                            ),
                                          ),
                                    ),
                                  ),
                                );
                              },
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
                              onPressed: () async {
                                if (!await _exigirLogin(context)) return;
                                if (!context.mounted) return;
                                if (_tamanhoSelecionado == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Selecione o tamanho antes de continuar.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                CarrinhoService.instancia.adicionar(
                                  CarrinhoItem(
                                    produto: produto,
                                    tamanho: _tamanhoSelecionado,
                                    quantidade: _quantidade,
                                  ),
                                );
                                if (!context.mounted) return;
                                Navigator.of(context).pushNamed('/checkout');
                              },
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

                          const SizedBox(height: 12),

                          // Botão dúvida
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: TextButton.icon(
                              onPressed: () => _abrirDialogDuvida(context),
                              icon: const Icon(
                                Icons.help_outline,
                                color: verde,
                                size: 20,
                              ),
                              label: const Text(
                                'Tire sua dúvida sobre o produto',
                                style: TextStyle(
                                  color: verde,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: verde,
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
