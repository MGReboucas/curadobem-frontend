import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class MeusEnderecosScreen extends StatefulWidget {
  const MeusEnderecosScreen({super.key});

  @override
  State<MeusEnderecosScreen> createState() => _MeusEnderecosScreenState();
}

class _MeusEnderecosScreenState extends State<MeusEnderecosScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  List<Map<String, String>> _enderecos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarEnderecos();
  }

  Future<void> _carregarEnderecos() async {
    final response = await ApiService.get('/usuario/enderecos');
    if (!mounted) return;
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _enderecos = data.map((e) {
          final m = e as Map<String, dynamic>;
          return {
            'id': m['id']?.toString() ?? '',
            'apelido': m['apelido']?.toString() ?? '',
            'rua': m['rua']?.toString() ?? '',
            'numero': m['numero']?.toString() ?? '',
            'complemento': m['complemento']?.toString() ?? '',
            'bairro': m['bairro']?.toString() ?? '',
            'cidade': m['cidade']?.toString() ?? '',
            'estado': m['estado']?.toString() ?? '',
            'cep': m['cep']?.toString() ?? '',
          };
        }).toList();
        _carregando = false;
      });
    } else {
      setState(() => _carregando = false);
    }
  }

  Future<void> _remover(int index) async {
    final id = _enderecos[index]['id'] ?? '';
    if (id.isNotEmpty) {
      await ApiService.delete('/usuario/enderecos/$id');
    }
    if (!mounted) return;
    setState(() => _enderecos.removeAt(index));
  }

  void _abrirFormulario({Map<String, String>? endereco, int? index}) {
    final apelidoCtrl = TextEditingController(text: endereco?['apelido'] ?? '');
    final cepCtrl = TextEditingController(text: endereco?['cep'] ?? '');
    final ruaCtrl = TextEditingController(text: endereco?['rua'] ?? '');
    final numCtrl = TextEditingController(text: endereco?['numero'] ?? '');
    final compCtrl = TextEditingController(
      text: endereco?['complemento'] ?? '',
    );
    final bairroCtrl = TextEditingController(text: endereco?['bairro'] ?? '');
    final cidadeCtrl = TextEditingController(text: endereco?['cidade'] ?? '');
    final estadoCtrl = TextEditingController(text: endereco?['estado'] ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        index != null ? 'Editar endereço' : 'Novo endereço',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: verde,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.black38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _campo(
                    'Apelido (ex: Casa, Trabalho)',
                    apelidoCtrl,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _campo(
                          'CEP',
                          cepCtrl,
                          keyboardType: TextInputType.number,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _campo(
                    'Rua',
                    ruaCtrl,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _campo(
                          'Número',
                          numCtrl,
                          keyboardType: TextInputType.number,
                          formatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: _campo('Complemento', compCtrl)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _campo('Bairro', bairroCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _campo(
                          'Cidade',
                          cidadeCtrl,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _campo(
                          'UF',
                          estadoCtrl,
                          formatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z]'),
                            ),
                            LengthLimitingTextInputFormatter(2),
                          ],
                          validator: (v) =>
                              (v == null || v.length < 2) ? 'Inválida' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false))
                          return;
                        final body = {
                          'apelido': apelidoCtrl.text,
                          'rua': ruaCtrl.text,
                          'numero': numCtrl.text,
                          'complemento': compCtrl.text,
                          'bairro': bairroCtrl.text,
                          'cidade': cidadeCtrl.text,
                          'estado': estadoCtrl.text.toUpperCase(),
                          'cep': cepCtrl.text,
                        };
                        final response = index != null
                            ? await ApiService.put(
                                '/usuario/enderecos/${_enderecos[index]['id']}',
                                body,
                              )
                            : await ApiService.post('/usuario/enderecos', body);
                        if (!context.mounted) return;
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          Navigator.of(context).pop();
                          _carregarEnderecos();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verde,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Salvar',
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
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black45),
        filled: true,
        fillColor: const Color(0xFFF9F7F3),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDD8CC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDD8CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: verde, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
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

            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator(color: verde))
                  : _enderecos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_off_outlined,
                            size: 64,
                            color: Color(0xFFCCC7B8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum endereço cadastrado',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _enderecos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final e = _enderecos[i];
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2E8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: verde,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['apelido'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${e['rua'] ?? ''}${(e['numero'] ?? '').isNotEmpty ? ', ${e['numero']}' : ''}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if ((e['complemento'] ?? '').isNotEmpty)
                                      Text(
                                        e['complemento']!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    Text(
                                      '${e['bairro']}, ${e['cidade']} - ${e['estado']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _abrirFormulario(endereco: e, index: i),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: verde,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    onPressed: () => _remover(i),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        backgroundColor: verde,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
