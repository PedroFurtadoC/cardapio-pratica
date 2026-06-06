import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/carrinho_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/pedido_confirmado_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/about_screen.dart';
import 'screens/admin_add_produto_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções geradas pela CLI FlutterFire.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CarrinhoProvider(),
      // DevicePreview fica ativo apenas em modo de desenvolvimento.
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
      // O cardápio é aberto: o app inicia direto na tela principal.
      // O login (Firebase) é solicitado ao finalizar o pedido, e a área
      // administrativa tem o seu próprio acesso restrito.
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/about': (context) => const AboutScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/pedido-confirmado': (context) => const PedidoConfirmadoScreen(),
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin': (context) => const AdminScreen(),
        '/admin/add-produto': (context) => const AdminAddProdutoScreen(),
      },
    );
  }
}
