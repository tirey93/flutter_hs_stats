
import 'dart:convert';

import 'package:collection/collection.dart';
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
    return await fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is kocham Goferka'),
      ),
      body: Center(
        child: FutureBuilder<Summary>(
          future: futureSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); 
            }
            else if (snapshot.hasData) {    
              var summary = snapshot.data!;
              var res1 = summary.expansions.entries
                .where((x) => x.key != 'WILD')
                .sorted((a, b) => -a.value.releaseYear!.compareTo(b.value.releaseYear!))
                .groupListsBy((x) => x.value.yearName);
                
              return ListView.builder(
                itemCount: res1.length + 1,
                itemBuilder: (context, index) {
                  if(index == res1.length){
                    return Text("wild");
                  }

                  final year = res1.entries.toList()[index].value
                    .sorted((a, b) => a.value.releaseMonth!.compareTo(b.value.releaseMonth!));
                  return makeCard(year);
                });
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

  Card makeCard(List<MapEntry<String, Expansion>> expansions) {
    return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(expansions.firstOrNull!.value.yearName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                  const Spacer(),
                  Text(getSum(expansions).toString()),
                  const SizedBox(width: 80),
                  Text((getSum(expansions) / getMonths(expansions)).toStringAsFixed(2)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
              child: Table(
                border: TableBorder.all(width: 1),
                children: [
                  TableRow(children: [
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(expansions[0].value.shortName))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(expansions[1].value.shortName))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(expansions[2].value.shortName))),
                  ]),
                  TableRow(
                    children: [
                      Center(child: Padding(padding: EdgeInsets.all(5), child: Text(expansions[0].value.sumAll().toString()))),
                      Center(child: Padding(padding: EdgeInsets.all(5), child: Text(expansions[1].value.sumAll().toString()))),
                      Center(child: Padding(padding: EdgeInsets.all(5), child: Text(expansions[2].value.sumAll().toString()))),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );
  }

  int getMonths(List<MapEntry<String, Expansion>> expansions) {
    if(expansions.firstOrNull!.value.releaseYear == null){
      var now = DateTime.now();
      var daysDiff = DateTime(now.year + 1, 4, 1).difference(now).inDays;

      return (daysDiff +1) ~/ 30;

    }
    return 12;

  }

  int getSum(List<MapEntry<String, Expansion>> expansions){
    int result = 0;
    for (var expansion in expansions) {
      result += expansion.value.sumAll();
    }
    return result;
  }
}