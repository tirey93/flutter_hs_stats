import 'package:flutter/material.dart';
import 'package:hs_stats/Data/summary.dart';
import 'package:hs_stats/hs_expansion.dart';

class YearCard extends StatefulWidget {
  final List<MapEntry<String, Expansion>> expansions;
  final Color color;
  const YearCard({super.key, required this.expansions, required this.color});

  @override
  State<YearCard> createState() => _YearCardState();
}

class _YearCardState extends State<YearCard> {
  int getSum(List<MapEntry<String, Expansion>> expansions){
    int result = 0;
    for (var expansion in expansions) {
      result += expansion.value.sumAll();
    }
    return result;
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      surfaceTintColor: widget.color,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HearthstoneExpansionPage(widget.expansions, widget.color))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(widget.expansions.firstOrNull!.value.yearName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
                  Expanded(flex: 1, child: Text(getSum(widget.expansions).toString())),
                  Expanded(flex: 1, child: Text((getSum(widget.expansions) / 12).toStringAsFixed(2))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
              child: Table(
                border: TableBorder.all(width: 1),
                children: [
                  TableRow(children: [
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansions[0].value.shortName))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansions[1].value.shortName))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansions[2].value.shortName))),
                  ]),
                  TableRow(
                    children: [
                      Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansions[0].value.sumAll().toString()))),
                      Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansions[1].value.sumAll().toString()))),
                      Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansions[2].value.sumAll().toString()))),
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
}