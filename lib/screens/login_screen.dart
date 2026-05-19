import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool carregando = false;
  String? erroMensagem;

  final Color verde = const Color(0xFF627348);
  final Color bege = const Color(0xFFF3EBD6);

  static const String _usuarioValido = 'admin';
  static const String _senhaValida = 'admin123';

  void entrar() async {
    final login = loginController.text.trim();
    final senha = senhaController.text;

    // Validação de campos vazios
    if (login.isEmpty || senha.isEmpty) {
      setState(() {
        erroMensagem = 'Preencha o usuário e a senha.';
      });
      return;
    }

    setState(() {
      carregando = true;
      erroMensagem = null;
    });

    // Simula chamada de autenticação
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      carregando = false;
    });

    if (login == _usuarioValido && senha == _senhaValida) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(usuario: login)),
      );
    } else {
      setState(() {
        erroMensagem = 'Usuário ou senha inválidos.';
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
            Container(
              height: 145,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/images/logo.png", height: 85),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CadastroScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Não tem conta?",
                      style: TextStyle(
                        color: verde,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PÁGINA DE LOGIN",
                      style: TextStyle(
                        color: verde,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      "Usuário ou email:",
                      style: TextStyle(
                        color: verde,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: loginController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Digite seu login",
                        hintStyle: TextStyle(color: verde.withOpacity(0.8)),
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

                    const SizedBox(height: 18),

                    Text(
                      "Senha:",
                      style: TextStyle(
                        color: verde,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Digite sua senha",
                        hintStyle: TextStyle(color: verde.withOpacity(0.8)),
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

                    const SizedBox(height: 22),

                    GestureDetector(
                      onTap: () {
                        // recuperar senha
                      },
                      child: Text(
                        "Esqueceu sua senha?",
                        style: TextStyle(
                          color: verde,
                          fontSize: 24,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    if (erroMensagem != null) ...[
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
                          erroMensagem!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: carregando ? null : entrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 0,
                        ),
                        child: carregando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Entrar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
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
}
