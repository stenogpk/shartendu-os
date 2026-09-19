import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();

  runApp(const ShartenduOS());
}

class ShartenduOS extends StatelessWidget {
  const ShartenduOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shartendu OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3F5185),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const HomeScreen(),
    );
  }
}
