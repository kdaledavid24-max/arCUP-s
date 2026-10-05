import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/system_zoom_provider.dart';
import 'theme/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodOrderingApp());
}

/// Root widget of the Food Ordering Application.
class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => SystemZoomProvider()),
      ],
      child: MaterialApp(
        title: 'Food Ordering',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const MainNavigationScreen(initialIndex: 0),
          '/menu': (context) => const MainNavigationScreen(initialIndex: 1),
          '/cart': (context) => const MainNavigationScreen(initialIndex: 2),
          '/orders': (context) => const MainNavigationScreen(initialIndex: 3),
          '/profile': (context) => const MainNavigationScreen(initialIndex: 4),
          '/checkout': (context) => const CheckoutScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}
