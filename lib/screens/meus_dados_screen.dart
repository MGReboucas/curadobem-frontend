import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

String _formatTelefone(String digits) {
  final d = digits.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return '';
  if (d.length <= 2) return '(${d}';
  if (d.length <= 6) return '(${d.substring(0, 2)}) ${d.substring(2)}';
  if (d.length <= 10) {
    return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
  }
  return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7, 11)}';
}

class _TelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'\D'), '')
        .substring(
          0,
          newValue.text.replaceAll(RegExp(r'\D'), '').length.clamp(0, 11),
        );
    final formatted = _formatTelefone(digits);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class MeusDadosScreen extends StatefulWidget {
  const MeusDadosScreen({super.key});

  @override
  State<MeusDadosScreen> createState() => _MeusDadosScreenState();
}

class _MeusDadosScreenState extends State<MeusDadosScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  bool _salvando = false;
  Uint8List? _fotoBytes;
  String? _fotoUrl;
  bool _enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final response = await ApiService.get('/usuario/perfil');
    if (!mounted) return;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        _nomeController.text = data['nome_completo']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _telefoneController.text = _formatTelefone(
          data['telefone']?.toString() ?? '',
        );
        _fotoUrl = data['foto_url']?.toString();
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _fotoBytes = bytes;
      _enviandoFoto = true;
    });
    final response = await ApiService.uploadFoto(bytes, xFile.name);
    if (!mounted) return;
    setState(() => _enviandoFoto = false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final novaFoto = ApiService.resolverFotoUrl(
        data['foto_url']?.toString() ?? _fotoUrl,
      );
      setState(() => _fotoUrl = novaFoto);
      if (novaFoto != null) await ApiService.saveFotoUrl(novaFoto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto atualizada com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _fotoBytes = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar a foto.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _salvando = true);
    final response = await ApiService.put('/usuario/perfil', {
      'nome_completo': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'telefone': _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
    });
    if (!mounted) return;
    setState(() => _salvando = false);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados salvos com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar dados.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bege,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar
                      Center(
                        child: GestureDetector(
                          onTap: _enviandoFoto ? null : _escolherFoto,
                          child: Stack(
                            children: [
                              Builder(
                                builder: (context) {
                                  final url =
                                      _fotoUrl != null && _fotoUrl!.isNotEmpty
                                      ? (_fotoUrl!.startsWith('http')
                                            ? _fotoUrl!
                                            : 'http://127.0.0.1:8000$_fotoUrl')
                                      : null;
                                  Widget fotoWidget;
                                  if (_fotoBytes != null) {
                                    fotoWidget = Image.memory(
                                      _fotoBytes!,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    );
                                  } else if (url != null) {
                                    fotoWidget = Image.network(
                                      url,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(
                                          _nomeController.text.isNotEmpty
                                              ? _nomeController.text[0]
                                                    .toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: verde,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    fotoWidget = Center(
                                      child: Text(
                                        _nomeController.text.isNotEmpty
                                            ? _nomeController.text[0]
                                                  .toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: verde,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: 88,
                                    height: 88,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F0E0),
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: fotoWidget,
                                  );
                                },
                              ),
                              if (_enviandoFoto)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black38,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: verde,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildCampo(
                        label: 'Nome completo',
                        controller: _nomeController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o nome'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _buildCampo(
                        label: 'E-mail',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Informe o e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildCampo(
                        label: 'Telefone',
                        controller: _telefoneController,
                        hint: '(00) 00000-0000',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_TelefoneFormatter()],
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _salvando ? null : _salvar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: verde,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            elevation: 0,
                          ),
                          child: _salvando
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Salvar alterações',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildCampo({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDD8CC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDD8CC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: verde, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
