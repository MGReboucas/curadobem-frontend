import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  int _etapa = 1; // 1 = e-mail, 2 = código, 3 = nova senha

  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaSenhaCtrl = TextEditingController();

  bool _carregando = false;
  String? _erro;
  bool _senhaVisivel = false;
  bool _confirmaSenhaVisivel = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codigoCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _erro = 'Informe um e-mail válido.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    final res = await AuthService.solicitarRedefinicao(email);
    if (!mounted) return;
    setState(() => _carregando = false);
    if (res['sucesso'] == true) {
      setState(() => _etapa = 2);
    } else {
      setState(() => _erro = res['mensagem'] ?? 'Erro ao enviar código.');
    }
  }

  Future<void> _verificarCodigo() async {
    final codigo = _codigoCtrl.text.trim();
    if (codigo.length != 6) {
      setState(() => _erro = 'O código deve ter 6 dígitos.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    final res = await AuthService.verificarCodigo(
      _emailCtrl.text.trim(),
      codigo,
    );
    if (!mounted) return;
    setState(() => _carregando = false);
    if (res['sucesso'] == true) {
      setState(() => _etapa = 3);
    } else {
      setState(() => _erro = res['mensagem'] ?? 'Código inválido ou expirado.');
    }
  }

  Future<void> _redefinirSenha() async {
    final senha = _senhaCtrl.text;
    final confirma = _confirmaSenhaCtrl.text;
    if (senha.length < 6) {
      setState(() => _erro = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }
    if (senha != confirma) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    final res = await AuthService.redefinirSenha(
      _emailCtrl.text.trim(),
      _codigoCtrl.text.trim(),
      senha,
      confirma,
    );
    if (!mounted) return;
    setState(() => _carregando = false);
    if (res['sucesso'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso! Faça login.'),
          backgroundColor: verde,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      setState(() => _erro = res['mensagem'] ?? 'Erro ao redefinir senha.');
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (_etapa > 1) {
                        setState(() {
                          _etapa--;
                          _erro = null;
                        });
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: verde,
                      size: 14,
                    ),
                    label: const Text(
                      'Voltar',
                      style: TextStyle(
                        color: verde,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    Center(
                      child: Image.asset('assets/images/logo.png', height: 90),
                    ),

                    const SizedBox(height: 36),

                    // Indicador de etapas
                    _StepIndicator(etapaAtual: _etapa),

                    const SizedBox(height: 32),

                    if (_etapa == 1) _etapa1(),
                    if (_etapa == 2) _etapa2(),
                    if (_etapa == 3) _etapa3(),

                    if (_erro != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _erro!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _carregando
                            ? null
                            : _etapa == 1
                            ? _enviarCodigo
                            : _etapa == 2
                            ? _verificarCodigo
                            : _redefinirSenha,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 0,
                        ),
                        child: _carregando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _etapa == 1
                                    ? 'Enviar código'
                                    : _etapa == 2
                                    ? 'Verificar código'
                                    : 'Redefinir senha',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etapa1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESQUECEU A SENHA?',
          style: TextStyle(
            color: verde,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Informe seu e-mail e enviaremos um código de verificação.',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        const Text(
          'E-mail:',
          style: TextStyle(
            color: verde,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'seu@email.com',
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _etapa2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DIGITE O CÓDIGO',
          style: TextStyle(
            color: verde,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos um código de 6 dígitos para ${_emailCtrl.text.trim()}.',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        const Text(
          'Código:',
          style: TextStyle(
            color: verde,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codigoCtrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 10,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: const TextStyle(
              color: Colors.black26,
              letterSpacing: 10,
              fontSize: 28,
            ),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _carregando ? null : _enviarCodigo,
            child: const Text(
              'Reenviar código',
              style: TextStyle(
                color: verde,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: verde,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _etapa3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NOVA SENHA',
          style: TextStyle(
            color: verde,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Escolha uma nova senha para sua conta.',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        const Text(
          'Nova senha:',
          style: TextStyle(
            color: verde,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _senhaCtrl,
          obscureText: !_senhaVisivel,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Mínimo 6 caracteres',
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                color: verde,
              ),
              onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Confirmar senha:',
          style: TextStyle(
            color: verde,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmaSenhaCtrl,
          obscureText: !_confirmaSenhaVisivel,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Repita a nova senha',
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _confirmaSenhaVisivel ? Icons.visibility_off : Icons.visibility,
                color: verde,
              ),
              onPressed: () => setState(
                () => _confirmaSenhaVisivel = !_confirmaSenhaVisivel,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int etapaAtual;

  const _StepIndicator({required this.etapaAtual});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Step(numero: 1, label: 'E-mail', ativo: etapaAtual >= 1),
        _StepLine(ativo: etapaAtual >= 2),
        _Step(numero: 2, label: 'Código', ativo: etapaAtual >= 2),
        _StepLine(ativo: etapaAtual >= 3),
        _Step(numero: 3, label: 'Senha', ativo: etapaAtual >= 3),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int numero;
  final String label;
  final bool ativo;

  const _Step({required this.numero, required this.label, required this.ativo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ativo ? const Color(0xFF627348) : Colors.white,
            border: Border.all(color: const Color(0xFF627348), width: 2),
          ),
          child: Center(
            child: Text(
              '$numero',
              style: TextStyle(
                color: ativo ? Colors.white : const Color(0xFF627348),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: ativo ? const Color(0xFF627348) : Colors.black38,
            fontSize: 11,
            fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool ativo;

  const _StepLine({required this.ativo});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 2,
          color: ativo
              ? const Color(0xFF627348)
              : const Color(0xFF627348).withOpacity(0.2),
        ),
      ),
    );
  }
}
