import 'package:flutter/material.dart';

import '../chatbot.dart';
import '../models/bot.dart';
import '../storage.dart';
import '../widgets.dart';
import 'profile_screen.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  List<Bot> _bots = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final bots = await Storage.getBotList();
    if (mounted) setState(() => _bots = bots);
  }

  Future<void> _openForm({String? botId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ProfileScreen(editBotId: botId)),
    );
    _reload();
  }

  Future<void> _run(Future<void> Function() action, [String? success]) async {
    try {
      await action();
      if (success != null && mounted) showInfoAlert(context, success);
    } catch (e) {
      if (mounted) showErrorAlert(context, e.toString());
    }
  }

  void _showActions(Bot bot) {
    final actions = <(String, VoidCallback, bool)>[
      ('🤖 Start Bot', () => _run(() => Chatbot.startBot(bot)), false),
      // Same visibility rules as the iOS tester app.
      if (bot.apiKey.isNotEmpty &&
          bot.ymAuthToken.isNotEmpty &&
          bot.enableNotification)
        (
          'Register Device',
          () => _run(() => Chatbot.registerDevice(bot),
              'Device Registered Successfully'),
          false,
        ),
      if (bot.apiKey.isNotEmpty && bot.enableNotification)
        (
          'Unlink Device Token',
          () => _run(() => Chatbot.unlinkDeviceToken(bot),
              'Device Unlinked Successfully'),
          false,
        ),
      ('Edit', () => _openForm(botId: bot.id), false),
      (
        'Delete',
        () async {
          await Storage.deleteBot(bot.id);
          _reload();
        },
        true,
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(bot.id, style: Theme.of(context).textTheme.bodySmall),
            for (final (title, onTap, destructive) in actions)
              ListTile(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: destructive ? Colors.red : null,
                    fontSize: 17,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onTap();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add profile',
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: _bots.isEmpty
          ? const Center(child: Text('No profiles yet. Tap + to add a bot.'))
          : ListView.separated(
              itemCount: _bots.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final bot = _bots[index];
                return ListTile(
                  title: Text(bot.name.isEmpty ? 'Unnamed' : bot.name),
                  subtitle: Text(bot.id),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showActions(bot),
                );
              },
            ),
    );
  }
}
