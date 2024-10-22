
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_stats/Data/summary.dart';
import 'package:hs_stats/hs_expansion.dart';
import 'package:hs_stats/widgets/expansion_card.dart';
import 'package:intl/intl.dart';

class HearthstoneYearsPage extends StatefulWidget {
  const HearthstoneYearsPage({super.key});

  @override
  State<HearthstoneYearsPage> createState() => _HearthstoneYearsPageState();
}

class _HearthstoneYearsPageState extends State<HearthstoneYearsPage> {
  Future<Summary>? futureSummary;
  final cacheManager = DefaultCacheManager();
  final cacheKey = 'hearthstoneKey';
  String session = "";
  String infoDust = "";
  String infoDateModified = "";
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getSession();
    futureSummary = loadSummary();
  }
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<void> _pullRefresh() async {
    var summary = loadSummary(forceRefresh: true);
    setState(() {
      futureSummary = Future.value(summary);
    });
  }

  Future<void> getSession() async{
    var fileInfo = await cacheManager.getFileFromCache('sessionKey');
    if (fileInfo != null) {
      final cachedData = await fileInfo.file.readAsString();
      var res = jsonDecode(cachedData);
      setState(() {
        session = res;
        myController.text = session;
    });
    }
  }
  _saveSession()  {
    cacheManager.putFile(
      'sessionKey',
      utf8.encode(jsonEncode(myController.text)),
      fileExtension: 'json',);
    setState(() {
      session = myController.text;
    });
  }

  Future<Summary>? loadSummary({bool forceRefresh = false}) async {
    if(forceRefresh)
      return await fetchSummary(session);
    var fileInfo = await cacheManager.getFileFromCache(cacheKey);
    if (fileInfo != null) {
      final cachedData = await fileInfo.file.readAsString();
      return Summary.fromJson(jsonDecode(cachedData));
    }
    return await fetchSummary(session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Years'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
            onPressed: () => _dialogInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Pull refresh',
            onPressed: () => _pullRefresh(),
          ),
          IconButton(
            icon: const Icon(Icons.edit_notifications_outlined),
            tooltip: 'Change session',
            onPressed: () => _dialogSession(context),
          ),
        ]
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
              return drawSummary(summary);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            
            return const Text('');
          },
        ),
      ),
    );
  }

  ListView drawSummary(Summary summary) {
    infoDust = summary.additionalInfo!.rares.toString();
    var dateTime = summary.additionalInfo!.lastModified;
    infoDateModified = DateFormat("dd-MM-yyyy HH:mm").format(dateTime);
    var years = summary.expansions.entries
      .sorted((a, b) => -a.value.releaseYear!.compareTo(b.value.releaseYear ?? 0))
      .groupListsBy((x) => x.value.yearName);
    
    var colors = [
      Colors.orange,
      Colors.blue,
    ];
    return ListView.builder(
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years.entries.toList()[index].value;
        if(year[0].key == "WILD"){
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
            child: ExpansionCard(expansion: year[0].value, color: Colors.black),
          );
        } 
        var yearSorted = year.sorted((a, b) => a.value.releaseMonth!.compareTo(b.value.releaseMonth!));
    
        return drawCard(yearSorted, colors[index]);
      });
  }

  Card drawCard(List<MapEntry<String, Expansion>> expansions, Color color) {
    return Card(
        elevation: 10,
        surfaceTintColor: color,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HearthstoneExpansionPage(expansions, color))),
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
  
  Future<void> _dialogSession(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('HS Replay session'),
          content: const Text(
            'Please type your HS replay session id.',
          ),
          actions: <Widget>[
            TextField(
              controller: myController,
              
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Save'),
              onPressed: () {
                _saveSession();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _dialogInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          actions: <Widget>[
            Table(
              children: [
                TableRow(
                  children: [
                    Text("Rares"),
                    Text(infoDust),
                  ]
                ),
                TableRow(
                  children: [
                    Text("Last modified"),
                    Text(infoDateModified),
                  ]
                ),
              ],
            ),
          ],
        );
      },
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