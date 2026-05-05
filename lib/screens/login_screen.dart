import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool carregando = false;

  final Color verde = const Color(0xFF627348);
  final Color bege = const Color(0xFFF3EBD6);

  void entrar() async {
    setState(() {
      carregando = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      carregando = false;
    });

    // Aqui depois você coloca sua navegação ou API
    print("Login: ${loginController.text}");
    print("Senha: ${senhaController.text}");
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
                      // ir para cadastro
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
