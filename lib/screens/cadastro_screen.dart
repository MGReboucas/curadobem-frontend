import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmaSenhaController = TextEditingController();

  bool aceitaTermos = false;
  bool aceitaPrivacidade = false;
  bool carregando = false;
  String? erroMensagem;

  final Color verde = const Color(0xFF627348);
  final Color bege = const Color(0xFFF3EBD6);

  void criarConta() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!aceitaTermos || !aceitaPrivacidade) {
      setState(() {
        erroMensagem =
            'Você deve aceitar os termos e a política de privacidade.';
      });
      return;
    }

    setState(() {
      carregando = true;
      erroMensagem = null;
    });

    final resultado = await AuthService.register(
      usuarioController.text.trim(),
      emailController.text.trim(),
      senhaController.text,
      confirmaSenhaController.text,
    );

    setState(() {
      carregando = false;
    });

    if (!mounted) return;

    if (resultado['sucesso'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      setState(() {
        erroMensagem = resultado['mensagem'] ?? 'Erro ao criar conta.';
      });
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmaSenhaController.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (_) => false);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: verde,
                      size: 14,
                    ),
                    label: Text(
                      'Voltar à loja',
                      style: TextStyle(
                        color: verde,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: verde,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    child: Text(
                      'Já possui conta?',
                      style: TextStyle(
                        color: verde,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: verde,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo centralizada
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 90,
                        ),
                      ),
                      const SizedBox(height: 40),

                      Text(
                        "PAGINA DE CADASTRO",
                        style: TextStyle(
                          color: verde,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Usuario
                      Text(
                        "Usuario:",
                        style: TextStyle(color: verde, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: usuarioController,
                        hint: "Digite seu usuario",
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o usuário'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // E-mail
                      Text(
                        "E-mail:",
                        style: TextStyle(color: verde, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: emailController,
                        hint: "Digite seu e-mail",
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Informe o e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Senha
                      Text(
                        "Senha:",
                        style: TextStyle(color: verde, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: senhaController,
                        hint: "Digite sua senha",
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirme a senha
                      Text(
                        "Confirme a senha:",
                        style: TextStyle(color: verde, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: confirmaSenhaController,
                        hint: "Digite a mesma senha",
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirme a senha';
                          if (v != senhaController.text)
                            return 'As senhas não coincidem';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Checkboxes
                      _buildCheckboxRow(
                        value: aceitaTermos,
                        onChanged: (v) =>
                            setState(() => aceitaTermos = v ?? false),
                        normalText: "Li e concordo com a ",
                        linkText: "Termo de condições",
                        onLinkTap: () {},
                      ),
                      const SizedBox(height: 8),
                      _buildCheckboxRow(
                        value: aceitaPrivacidade,
                        onChanged: (v) =>
                            setState(() => aceitaPrivacidade = v ?? false),
                        normalText: "Li e concordo com a ",
                        linkText: "politica de privacidade",
                        onLinkTap: () {},
                      ),

                      if (erroMensagem != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          erroMensagem!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Botão
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: carregando ? null : criarConta,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: verde,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: carregando
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Criar conta",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String normalText,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: verde,
          shape: const CircleBorder(),
          side: BorderSide(color: verde),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: verde, fontSize: 14),
              children: [
                TextSpan(text: normalText),
                TextSpan(
                  text: linkText,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
