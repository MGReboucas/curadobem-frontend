import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'meus_dados_screen.dart';
import 'meus_pedidos_screen.dart';
import 'meus_enderecos_screen.dart';
import 'duvidas_screen.dart';
import 'cupons_screen.dart';

class MenuClienteScreen extends StatefulWidget {
  const MenuClienteScreen({super.key});

  @override
  State<MenuClienteScreen> createState() => _MenuClienteScreenState();
}

class _MenuClienteScreenState extends State<MenuClienteScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  String _nome = '';
  String _email = '';
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
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
      setState(() {
        _nome =
            data['nome_completo']?.toString()?.trim() ??
            data['nome']?.toString()?.trim() ??
            data['username']?.toString()?.trim() ??
            '';
        _email = data['email']?.toString()?.trim() ?? '';
        final rawFoto = data['foto_url']?.toString()?.trim();
        _fotoUrl = rawFoto != null && rawFoto.isNotEmpty
            ? (rawFoto.startsWith('http')
                  ? rawFoto
                  : 'http://127.0.0.1:8000$rawFoto')
            : null;
      });
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Card de perfil
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F0E0),
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _fotoUrl != null
                                ? Image.network(
                                    _fotoUrl!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        _nome.isNotEmpty
                                            ? _nome[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: verde,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      _nome.isNotEmpty
                                          ? _nome[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: verde,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nome.isNotEmpty ? _nome : 'Usuário',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _email.isNotEmpty
                                    ? _email
                                    : 'usuario@email.com',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tiles do menu
                    _buildMenuTile(
                      context,
                      icon: Icons.person_outline,
                      title: 'Meus Dados',
                      subtitle: 'Editar informações do perfil',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MeusDadosScreen(),
                        ),
                      ),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      title: 'Meus Pedidos',
                      subtitle: 'Histórico de compras',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MeusPedidosScreen(),
                        ),
                      ),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Meus Endereços',
                      subtitle: 'Gerenciar endereços de entrega',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MeusEnderecosScreen(),
                        ),
                      ),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Dúvidas',
                      subtitle: 'Perguntas pendentes e respondidas',
                      badge: 2,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DuvidasScreen(),
                        ),
                      ),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.local_offer_outlined,
                      title: 'Cupons',
                      subtitle: 'Meus cupons de desconto',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CuponsScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botão Sair
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ApiService.clearToken();
                          await ApiService.clearNome();
                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (_) => false);
                        },
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          'Sair da conta',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    int? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: verde, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
