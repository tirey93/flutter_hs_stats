
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_stats/Data/summary.dart';

class HearthstonePage extends StatefulWidget {
  const HearthstonePage({super.key});

  @override
  State<HearthstonePage> createState() => _HearthstonePageState();
}

class _HearthstonePageState extends State<HearthstonePage> {
  Future<Summary>? futureSummary;
  final cacheManager = DefaultCacheManager();
  final cacheKey = 'hearthstoneKey';

  @override
  void initState() {
    super.initState();
    futureSummary = loadSummary();
  }

  Future<void> _pullRefresh() async {
    var summary = loadSummary(forceRefresh: true);
    setState(() {
      futureSummary = Future.value(summary);
    });
  }

  Future<Summary>? loadSummary({bool forceRefresh = false}) async {
    if(forceRefresh)
      return await fetchSummary();
    var fileInfo = await cacheManager.getFileFromCache(cacheKey);
    if (fileInfo != null) {
      final cachedData = await fileInfo.file.readAsString();
      return Summary.fromJson(jsonDecode(cachedData));
    }
    return Summary();
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
        onPressed: _pullRefresh,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }  
}