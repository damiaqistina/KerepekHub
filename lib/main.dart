import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/customer/catalog_screen.dart';
import 'screens/customer/cart/cart_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const KerepekHubApp(),
    ),
  );
}

class KerepekHubApp extends StatelessWidget {
  const KerepekHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KerepekHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF4C430),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Builder(
        builder: (context) {
          return CatalogScreen(
            onViewCartTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}