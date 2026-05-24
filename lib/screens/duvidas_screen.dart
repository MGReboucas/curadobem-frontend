import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DuvidasScreen extends StatefulWidget {
  const DuvidasScreen({super.key});

  @override
  State<DuvidasScreen> createState() => _DuvidasScreenState();
}

class _DuvidasScreenState extends State<DuvidasScreen>
    with SingleTickerProviderStateMixin {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  late final TabController _tabController;

  List<Map<String, dynamic>> _pendentes = [];
  List<Map<String, dynamic>> _respondidas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDuvidas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDuvidas() async {
    final response = await ApiService.get('/duvidas');
    if (!mounted) return;
    if (response.statusCode == 200) {
      final lista = (jsonDecode(response.body) as List)
          .cast<Map<String, dynamic>>();
      setState(() {
        _pendentes = lista.where((d) => d['status'] == 'pendente').toList();
        _respondidas = lista.where((d) => d['status'] == 'respondida').toList();
        _carregando = false;
      });
    } else {
      setState(() => _carregando = false);
    }
  }

  Future<void> _excluirDuvida(int id) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Excluir dúvida',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Deseja excluir esta pergunta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirma != true) return;
    final response = await ApiService.delete('/duvidas/$id');
    if (!mounted) return;
    if (response.statusCode == 204) {
      _carregarDuvidas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir a dúvida.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatarData(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
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

            // TabBar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: verde,
                unselectedLabelColor: Colors.black38,
                indicatorColor: verde,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pendentes'),
                        const SizedBox(width: 6),
                        if (_pendentes.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_pendentes.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Respondidas'),
                        const SizedBox(width: 6),
                        if (_respondidas.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: verde,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_respondidas.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator(color: verde))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLista(_pendentes, respondida: false),
                        _buildLista(_respondidas, respondida: true),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(
    List<Map<String, dynamic>> lista, {
    required bool respondida,
  }) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              respondida ? Icons.check_circle_outline : Icons.help_outline,
              size: 52,
              color: Colors.black12,
            ),
            const SizedBox(height: 12),
            Text(
              respondida
                  ? 'Nenhuma dúvida respondida.'
                  : 'Nenhuma dúvida pendente.',
              style: const TextStyle(color: Colors.black45, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: verde,
      onRefresh: _carregarDuvidas,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: lista.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = lista[i];
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
                    Expanded(
                      child: Text(
                        item['produto_nome']?.toString() ?? 'Produto',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: verde,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatarData(item['criado_em']?.toString()),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                        if (!respondida) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _excluirDuvida(item['id'] as int),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['pergunta']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                if (respondida &&
                    (item['resposta']?.toString() ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 16,
                          color: verde,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item['resposta']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!respondida) ...[
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'Aguardando resposta',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
