import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.initDatabase();
  runApp(const MineraSysApp());
}

class MineraSysApp extends StatelessWidget {
  const MineraSysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineraSys',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}