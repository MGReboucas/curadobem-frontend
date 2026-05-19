import 'package:flutter/material.dart';

class CuponsScreen extends StatefulWidget {
  const CuponsScreen({super.key});

  @override
  State<CuponsScreen> createState() => _CuponsScreenState();
}

class _CuponsScreenState extends State<CuponsScreen>
    with SingleTickerProviderStateMixin {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  late final TabController _tabController;

  final List<Map<String, String>> _ativos = [
    {
      'codigo': 'BOAS-VINDAS10',
      'descricao': '10% de desconto na primeira compra',
      'tipo': 'porcentagem',
      'valor': '10%',
      'validade': 'Válido até 31/12/2026',
    },
    {
      'codigo': 'FRETE-GRATIS',
      'descricao': 'Frete grátis em qualquer pedido',
      'tipo': 'frete',
      'valor': 'Frete grátis',
      'validade': 'Válido até 30/06/2026',
    },
    {
      'codigo': 'VERÃO25',
      'descricao': 'R\$ 25,00 de desconto em compras acima de R\$ 150,00',
      'tipo': 'valor',
      'valor': 'R\$ 25',
      'validade': 'Válido até 15/07/2026',
    },
  ];

  final List<Map<String, String>> _usados = [
    {
      'codigo': 'NATAL15',
      'descricao': '15% de desconto no Natal',
      'tipo': 'porcentagem',
      'valor': '15%',
      'validade': 'Expirou em 31/01/2026',
      'pedido': 'Pedido nº 0001089',
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

  void _copiarCodigo(BuildContext context, String codigo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cupom "$codigo" copiado!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
                tabs: const [
                  Tab(text: 'Ativos'),
                  Tab(text: 'Usados'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListaCupons(_ativos, usado: false),
                  _buildListaCupons(_usados, usado: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaCupons(
    List<Map<String, String>> lista, {
    required bool usado,
  }) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 56,
              color: Colors.black.withOpacity(0.15),
            ),
            const SizedBox(height: 12),
            Text(
              usado ? 'Nenhum cupom usado.' : 'Nenhum cupom disponível.',
              style: const TextStyle(color: Colors.black45, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final c = lista[i];
        return _buildCupomCard(context, c, usado: usado);
      },
    );
  }

  Widget _buildCupomCard(
    BuildContext context,
    Map<String, String> cupom, {
    required bool usado,
  }) {
    return Opacity(
      opacity: usado ? 0.6 : 1.0,
      child: Container(
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Lado esquerdo — desconto em destaque
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: usado
                      ? Colors.black12
                      : const Color(0xFF627348).withOpacity(0.12),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cupom['tipo'] == 'frete'
                          ? Icons.local_shipping_outlined
                          : Icons.local_offer_outlined,
                      color: usado ? Colors.black38 : verde,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cupom['valor'] ?? '',
                      style: TextStyle(
                        fontSize: cupom['valor']!.length > 4 ? 13 : 16,
                        fontWeight: FontWeight.w900,
                        color: usado ? Colors.black38 : verde,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Divisor tracejado
              CustomPaint(
                size: const Size(1, double.infinity),
                painter: _DashedLinePainter(
                  color: usado ? Colors.black12 : const Color(0xFFDDD8CC),
                ),
              ),

              // Conteúdo principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cupom['codigo'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          if (!usado)
                            GestureDetector(
                              onTap: () =>
                                  _copiarCodigo(context, cupom['codigo'] ?? ''),
                              child: const Icon(
                                Icons.copy_outlined,
                                size: 18,
                                color: verde,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cupom['descricao'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cupom['validade'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: usado ? Colors.black38 : Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (usado && (cupom['pedido'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          cupom['pedido'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashHeight = 6.0;
    const dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
