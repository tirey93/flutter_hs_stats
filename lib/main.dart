import 'package:flutter/material.dart';
import 'package:hs_stats/pages/years_page.dart';

void main() {
  var configFuture = cfg.Config.init();
  configFuture.then((_) {
    runApp(const MainApp());
  });
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
