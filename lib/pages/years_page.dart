import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_stats/data/summary.dart';
import 'package:hs_stats/widgets/expansion_card.dart';
import 'package:hs_stats/widgets/info_dialog.dart';
import 'package:hs_stats/widgets/session_input_dialog.dart';
import 'package:hs_stats/widgets/year_card.dart';
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

  @override
  void initState() {
    super.initState();
    getSession();
    futureSummary = loadSummary();
  }

  Future<void> getSession() async{
    var fileInfo = await cacheManager.getFileFromCache('sessionKey');
    if (fileInfo != null) {
      final cachedData = await fileInfo.file.readAsString();
      var res = jsonDecode(cachedData);
      setState(() {
        session = res;
    });
    }
  }

  Future<void> _pullRefresh() async {
    setState(() {
      futureSummary = loadSummary(forceRefresh: true);
    });
  }
  _saveSession(String session)  {
    cacheManager.putFile(
      'sessionKey',
      utf8.encode(jsonEncode(session)),
      fileExtension: 'json',);
    _pullRefresh();
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
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Change session',
            onPressed: () => _dialogSession(context),
          ),
        ]
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Center(
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
                return Column(
                  children: [
                    Text('${snapshot.error}'),
                    TextButton(onPressed: _pullRefresh, child: const Text('Refresh'),),
                  ],
                );
              }
              return const Text('');
            },
          ),
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
    
        return YearCard(expansions: yearSorted,color: colors[index]);
      });
  }
  
  Future<void> _dialogSession(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SessionInputDialog(initialSession: session, 
          onSave: (newSession) => {
            setState(() {
              session = newSession;
              _saveSession(session);
            })
          });
      },
    );
  }
  Future<void> _dialogInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return InfoDialog(infoDust: infoDust, infoDateModified: infoDateModified);
      },
    );
  }
}