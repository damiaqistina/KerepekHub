
import 'package:flutter/material.dart';
import 'package:kerepekhub/screens/owner/authentication.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/order_provider.dart';
import 'screens/customer/catalog_screen.dart';
import 'screens/customer/feedback_screen.dart';
import 'screens/customer/order_history_screen.dart';
import 'screens/owner/payment_verification_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
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
      home: const CustomerShell(),
      routes: {"/payments": (context) => const PaymentVerificationScreen()
      },
    );
  }
}

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const CatalogScreen(), // UI-02
      OrderHistoryScreen(
        onBackToHomeTap: () => setState(() => _currentIndex = 0),
      ), // UI-05
      const FeedbackScreen(), // UI-06
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Reviews',
          ),
        ],
      ),
    );
  }
}
