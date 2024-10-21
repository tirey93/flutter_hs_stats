
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hs_stats/Data/summary.dart';

class HearthstonePage extends StatefulWidget {
  const HearthstonePage({super.key});

  @override
  State<HearthstonePage> createState() => _HearthstonePageState();
}

class _HearthstonePageState extends State<HearthstonePage> {
  Future<Summary>? futureSummary;

  void _loadData() {
    setState(() {
      futureSummary = fetchSummary();
    });
  }

  @override
  void initState() {
    super.initState();
    futureSummary = fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is hearthstone screen'),
      ),
      body: Center(
        child: FutureBuilder<Summary>(
          future: futureSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); 
            }
            else if (snapshot.hasData) {
              // var res = jsonEncode(snapshot.data!);
              JsonEncoder encoder = const JsonEncoder.withIndent('  ');
               String prettyprint = encoder.convert(snapshot.data!);
               return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(prettyprint),
               );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const Text('');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

