import 'package:flutter/material.dart';

class SessionInputDialog extends StatefulWidget {
  final String initialSession;
  final Function(String) onSave;

  const SessionInputDialog({
    super.key,
    required this.initialSession,
    required this.onSave,
  });

  @override
  State<SessionInputDialog> createState() => _SessionInputDialogState();
}

class _SessionInputDialogState extends State<SessionInputDialog> {
  late TextEditingController _textController;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialSession);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('HS Replay session'),
      content: const Text(
        'Please type your HS replay session id.',
      ),
      actions: <Widget>[
        TextField(
          controller: _textController,
          
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Save'),
          onPressed: () {
            widget.onSave(_textController.text);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}