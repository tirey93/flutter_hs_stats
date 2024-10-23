import 'package:flutter/material.dart';

class InfoDialog extends StatefulWidget {
  final String infoDust;
  final String infoDateModified;
  const InfoDialog({super.key, required this.infoDust, required this.infoDateModified});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Row(
                children: [
                  Expanded(flex: 3, child: const Text("Rares")),
                  Expanded(flex: 2, child: Text('')),
                  Expanded(flex: 4, child: Text(widget.infoDust)),
                ],
              ),
            ),
            ListTile(
                title: Row(
                  children: [
                    Expanded(flex: 3, child: const Text("Last modified")),
                    Expanded(flex: 2, child: Text('')),
                    Expanded(flex: 4, child: Text(widget.infoDateModified)),
                  ],
                ),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
  }
}