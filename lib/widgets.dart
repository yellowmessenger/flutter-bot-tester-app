import 'package:flutter/material.dart';

void showErrorAlert(BuildContext context, String message) =>
    _showAlert(context, 'Error', message);

void showInfoAlert(BuildContext context, String message) =>
    _showAlert(context, null, message);

void _showAlert(BuildContext context, String? title, String message) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Labelled form row used by the profile form.
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
