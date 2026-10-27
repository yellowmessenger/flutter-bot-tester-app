import 'package:flutter/material.dart';

import '../models/bot.dart';
import '../storage.dart';
import '../widgets.dart';

/// JSON payload editor. Returns the saved text to the profile form.
class PayloadScreen extends StatefulWidget {
  const PayloadScreen({super.key, required this.botId, required this.payload});

  final String botId;
  final String payload;

  @override
  State<PayloadScreen> createState() => _PayloadScreenState();
}

class _PayloadScreenState extends State<PayloadScreen> {
  late final _controller = TextEditingController(text: widget.payload);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text;
    if (!isValidPayload(text)) {
      showErrorAlert(context, 'Payload not compatible with JSON format');
      return;
    }
    // Like the iOS app, persist straight away if the profile already exists.
    final bot = await Storage.getBot(widget.botId);
    if (bot != null) await Storage.saveBot(bot.copyWith(payload: text));
    if (mounted) Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payload'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('JSON object sent to the bot as the session payload.'),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                autocorrect: false,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  hintText: '{\n  "key": "value"\n}',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
