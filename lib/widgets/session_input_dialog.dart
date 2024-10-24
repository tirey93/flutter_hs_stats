import 'package:flutter/material.dart';
import 'package:hs_stats/data/collection.dart';

class SessionInputDialog extends StatefulWidget {
  final Auth initialAuth;
  final Function(Auth) onSave;

  const SessionInputDialog({
    super.key,
    required this.initialAuth,
    required this.onSave,
  });

  @override
  State<SessionInputDialog> createState() => _SessionInputDialogState();
}

class _SessionInputDialogState extends State<SessionInputDialog> {
  late TextEditingController _sessionController;
  late TextEditingController _loginController;
  @override
  void dispose() {
    _sessionController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController(text: widget.initialAuth.login);
    _sessionController = TextEditingController(text: widget.initialAuth.session);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('HS Replay authentication'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please type your HSReplay info',
          ),
          const Text(
            'Don\'t know how? Check the manual on',
          ),
          const Text(
            'github.com/tirey93/flutter_hs_stats',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: <Widget>[
        TextField(
          controller: _loginController,
          decoration: InputDecoration(
            labelText: 'account_lo',
            hintText: 'Enter account_lo'
          ),
        ),
        TextField(
          controller: _sessionController,
          decoration: InputDecoration(
            labelText: 'sessionid',
            hintText: 'Enter sessionid'
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Save'),
          onPressed: () {
            widget.onSave(Auth(login: _loginController.text, session: _sessionController.text));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}