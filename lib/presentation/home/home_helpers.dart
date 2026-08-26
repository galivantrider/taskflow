import 'package:flutter/material.dart';

Future<bool> confirmDestructiveAction(BuildContext context, String title, String body) => showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text(title), content: Text(body), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))])).then((v) => v ?? false);
void showHomeSnack(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));