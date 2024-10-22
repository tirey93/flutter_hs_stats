import 'package:flutter/material.dart';
import 'package:hs_stats/Data/summary.dart';
import 'package:hs_stats/widgets/expansion_card.dart';

class HearthstoneExpansionPage extends StatefulWidget {
  final List<MapEntry<String, Expansion>> expansion;
  const HearthstoneExpansionPage(this.expansion, {super.key});

  @override
  State<HearthstoneExpansionPage> createState() => _HearthstoneExpansionPageState();
}

class _HearthstoneExpansionPageState extends State<HearthstoneExpansionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expansions'),
      ),
      body: ListView.builder(
        itemCount: widget.expansion.length,
        itemBuilder: (context, index) {
          final expansion = widget.expansion[index].value;
          if (expansion.sumAll() > 0)
            return ExpansionCard(expansion: expansion);
        })
    );
  }
}