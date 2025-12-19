import 'package:flutter/material.dart';
import 'package:hs_stats/pages/years_page.dart';
import 'package:hs_stats/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: HearthstoneYearsPage(),
      ),
    );
  }
}
