import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curado Bem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF627348)),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/cadastro': (_) => const CadastroScreen(),
      },
    );
  }
}
