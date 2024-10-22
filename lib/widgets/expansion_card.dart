import 'package:flutter/material.dart';
import 'package:hs_stats/Data/summary.dart';

class ExpansionCard extends StatefulWidget {
  final Expansion expansion;
  const ExpansionCard({super.key, required this.expansion});

  
  @override
  State<ExpansionCard> createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
            child: Table(
              columnWidths: {0: FixedColumnWidth(200)},
              children: [
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8), child: Text(getName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
                  Padding(padding: EdgeInsets.all(8), child: Text(widget.expansion.sumAll().toString())),
                  getAvarage(widget.expansion.releaseYear),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
            child: Table(
              border: TableBorder.all(width: 1),
              columnWidths: {0: FixedColumnWidth(60)},
              children: [
                TableRow(children: [
                  Center(child: Padding(padding: EdgeInsets.all(5), child: Text(''))),
                  Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text('Common'))),
                  Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text('Rare'))),
                  Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text('Epic'))),
                  Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text('Legendary'))),
                ]),
                TableRow(
                  children: [
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text('Normal'))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(''))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansion.rarities['RARE']!.getNormalCount().toString()))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansion.rarities['EPIC']!.getNormalCount().toString()))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansion.rarities['LEGENDARY']!.getNormalCount().toString()))),
                  ],
                ),
                TableRow(
                  children: [
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text('Golden'))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansion.rarities['COMMON']!.getPremiumCount().toString()))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansion.rarities['RARE']!.getPremiumCount().toString()))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansion.rarities['EPIC']!.getPremiumCount().toString()))),
                    Center(child: Padding(padding: EdgeInsets.all(5), child: Text(widget.expansion.rarities['LEGENDARY']!.getPremiumCount().toString()))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get getName {
    if (widget.expansion.releaseYear == null)
      return widget.expansion.yearName;
    return widget.expansion.fullName;
  }

  Widget getAvarage(int? releaseYear) {
    if (releaseYear == null)
      return Padding(padding: EdgeInsets.all(8), child: Text((widget.expansion.sumAll() / getMonths()).toStringAsFixed(2)));
    return Text('');
  }

  int getMonths() {
    var now = DateTime.now();
    var daysDiff = DateTime(now.year + 1, 4, 1).difference(now).inDays;

    return (daysDiff +1) ~/ 30;
  }
}