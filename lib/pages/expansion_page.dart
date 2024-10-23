import 'package:flutter/material.dart';
import 'package:hs_stats/data/expansion.dart';
import 'package:hs_stats/widgets/expansion_card.dart';

class HearthstoneExpansionPage extends StatefulWidget {
  final List<MapEntry<String, Expansion>> expansion;
  final Color color;
  const HearthstoneExpansionPage(this.expansion, this.color, {super.key});

  @override
  State<HearthstoneExpansionPage> createState() => _HearthstoneExpansionPageState();
}

class _HearthstoneExpansionPageState extends State<HearthstoneExpansionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expansion.firstOrNull!.value.yearName),
      ),
      body: ListView.builder(
        itemCount: widget.expansion.length,
        itemBuilder: (context, index) {
          final expansion = widget.expansion[index].value;
          if (expansion.sumAll() > 0)
            return ExpansionCard(expansion: expansion, color: widget.color);
          return Text('');
        })
    );
  }
}