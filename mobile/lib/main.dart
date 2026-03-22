import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

import 'providers/carrinho_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/pedido_confirmado_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/about_screen.dart';
import 'screens/admin_add_produto_screen.dart';

// Ativa o DevicePreview somente em modo de desenvolvimento
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CarrinhoProvider(),
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coração de Mãe',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15803D), // Verde Oficial
          secondary: const Color(0xFFF97316), // Laranja Oficial
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/about': (context) => const AboutScreen(),
        '/admin': (context) => const AdminScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/pedido-confirmado': (context) => const PedidoConfirmadoScreen(),
        '/admin/add-produto': (context) => const AdminAddProdutoScreen(),
      },
    );
  }
}