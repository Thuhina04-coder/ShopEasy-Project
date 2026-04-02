import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sqlite_init.dart' if (dart.library.html) 'sqlite_init_web.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/database_helper.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSqliteForDesktop();
  await DatabaseHelper.instance.database;
  runApp(const ShopEasyApp());
}

class ShopEasyApp extends StatelessWidget {
  const ShopEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'ShopEasy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _initialized = false;
  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (mounted) {
      if (auth.isLoggedIn) {
        await _loadUserData(auth.user!.id);
        _wasLoggedIn = true;
      }
      setState(() => _initialized = true);
    }
  }

  Future<void> _loadUserData(String userId) async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    await cart.loadForUser(userId);
    await orders.loadForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SplashScreen();
    }

    final auth = context.watch<AuthProvider>();

    // User just logged in — load their data
    if (auth.isLoggedIn && !_wasLoggedIn) {
      _wasLoggedIn = true;
      _loadUserData(auth.user!.id);
    }

    // User just logged out — clear in-memory state
    if (!auth.isLoggedIn && _wasLoggedIn) {
      _wasLoggedIn = false;
      context.read<CartProvider>().clearForLogout();
      context.read<OrderProvider>().clearForLogout();
    }

    if (auth.isLoggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
