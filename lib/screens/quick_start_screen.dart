import 'package:flutter/material.dart';

import '../chatbot.dart';
import '../widgets.dart';

class QuickStartScreen extends StatefulWidget {
  const QuickStartScreen({super.key});

  @override
  State<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends State<QuickStartScreen> {
  final _botIdController = TextEditingController();

  @override
  void dispose() {
    _botIdController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final botId = _botIdController.text.trim();
    if (botId.isEmpty) {
      showErrorAlert(context, 'Enter a valid bot id to start');
      return;
    }
    FocusScope.of(context).unfocus();
    try {
      await Chatbot.quickStart(botId);
    } catch (e) {
      if (mounted) showErrorAlert(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Start')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Use Quick Start to quickly launch a bot just using bot id.\n'
            'For advanced bot configuration and bot storage use Profiles',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _botIdController,
            decoration: const InputDecoration(
              hintText: 'Enter Bot Id. Eg: x0123456789',
              border: OutlineInputBorder(),
            ),
            autocorrect: false,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _start(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _start,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('Start Chat Bot', style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
    );
  }
}
