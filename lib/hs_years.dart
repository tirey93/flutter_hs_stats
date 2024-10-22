
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_stats/Data/summary.dart';
import 'package:hs_stats/widgets/expansion_card.dart';

class HearthstoneYearsPage extends StatefulWidget {
  const HearthstoneYearsPage({super.key});

  @override
  State<HearthstoneYearsPage> createState() => _HearthstoneYearsPageState();
}

class _HearthstoneYearsPageState extends State<HearthstoneYearsPage> {
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
              var years = summary.expansions.entries
                .sorted((a, b) => -a.value.releaseYear!.compareTo(b.value.releaseYear ?? 0))
                .groupListsBy((x) => x.value.yearName);
                
              return ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years.entries.toList()[index].value;
                  if(year[0].key == "WILD"){
                    return ExpansionCard(expansion: year[0].value);
                  }

                  
                  var yearSorted = year.sorted((a, b) => a.value.releaseMonth!.compareTo(b.value.releaseMonth!));
                  return makeCard(yearSorted);
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
        child: InkWell(
          onTap: () {
            debugPrint('Card tapped: ${expansions.firstOrNull!.value.yearName}');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
                child: Table(
                  columnWidths: {0: FixedColumnWidth(200)},
                  children: [
                    TableRow(children: [
                      Padding(padding: EdgeInsets.all(8), child: Text(expansions.firstOrNull!.value.yearName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
                      Padding(padding: EdgeInsets.all(8), child: Text(getSum(expansions).toString())),
                      Padding(padding: EdgeInsets.all(8), child: Text((getSum(expansions) / 12).toStringAsFixed(2))),
                    ]),
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
        ),
      );
  }

  int getSum(List<MapEntry<String, Expansion>> expansions){
    int result = 0;
    for (var expansion in expansions) {
      result += expansion.value.sumAll();
    }
    return result;
  }
}