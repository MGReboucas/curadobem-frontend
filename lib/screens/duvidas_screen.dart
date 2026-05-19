import 'package:flutter/material.dart';

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

  final List<Map<String, String>> _pendentes = [
    {
      'produto': 'Camisa Linho Bege',
      'pergunta': 'Esse tecido encolhe na lavagem?',
      'data': '08/05/2026',
    },
    {
      'produto': 'Calça Wide Leg Verde',
      'pergunta': 'Tem disponível no tamanho 38?',
      'data': '05/05/2026',
    },
  ];

  final List<Map<String, String>> _respondidas = [
    {
      'produto': 'Vestido Midi Floral',
      'pergunta': 'Qual o comprimento do vestido no tamanho M?',
      'resposta':
          'O comprimento no tamanho M é de 105 cm, medido do ombro até a barra. Qualquer dúvida, estamos à disposição!',
      'data': '20/04/2026',
    },
    {
      'produto': 'Blusa Tricô Off-White',
      'pergunta': 'A blusa é transparente?',
      'resposta':
          'Olá! A blusa possui uma trama mais fechada, portanto não é transparente. Fica ótima com ou sem camiseta por baixo.',
      'data': '12/04/2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                  const Tab(text: 'Respondidas'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
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
    List<Map<String, String>> lista, {
    required bool respondida,
  }) {
    if (lista.isEmpty) {
      return Center(
        child: Text(
          respondida
              ? 'Nenhuma dúvida respondida.'
              : 'Nenhuma dúvida pendente.',
          style: const TextStyle(color: Colors.black45, fontSize: 15),
        ),
      );
    }

    return ListView.separated(
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
                      item['produto'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: verde,
                      ),
                    ),
                  ),
                  Text(
                    item['data'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
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
                      item['pergunta'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              if (respondida && (item['resposta'] ?? '').isNotEmpty) ...[
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
                          item['resposta'] ?? '',
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
    );
  }
}
