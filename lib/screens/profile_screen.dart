import 'package:flutter/material.dart';

import '../models/bot.dart';
import '../storage.dart';
import '../widgets.dart';
import 'payload_screen.dart';

/// Add / Edit Profile. v3-only and v1/v2-only fields show based on Version,
/// like the iOS tester app's profile form.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.editBotId});

  final String? editBotId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _botId = TextEditingController();
  final _name = TextEditingController();
  final _initialUserMessage = TextEditingController();
  final _ymAuthToken = TextEditingController();
  final _apiKey = TextEditingController();
  final _customBaseURL = TextEditingController();

  int _version = 1;
  ActivationMode _activationMode = ActivationMode.chat;
  bool _enableSpeech = false;
  bool _enableLiteVersion = false;
  bool _enableNotification = false;
  String _payload = '';

  bool get _isEditing => widget.editBotId != null;

  @override
  void initState() {
    super.initState();
    if (widget.editBotId != null) _load(widget.editBotId!);
  }

  @override
  void dispose() {
    for (final c in [
      _botId,
      _name,
      _initialUserMessage,
      _ymAuthToken,
      _apiKey,
      _customBaseURL,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load(String botId) async {
    final bot = await Storage.getBot(botId);
    if (!mounted) return;
    if (bot == null) {
      showErrorAlert(context, 'Cannot find bot $botId. Please reinstall the app');
      return;
    }
    setState(() {
      _botId.text = bot.id;
      _name.text = bot.name;
      _version = bot.version;
      _activationMode = bot.activationMode;
      _initialUserMessage.text = bot.initialUserMessage;
      _enableSpeech = bot.enableSpeech;
      _enableLiteVersion = bot.enableLiteVersion;
      _ymAuthToken.text = bot.ymAuthToken;
      _apiKey.text = bot.apiKey;
      _enableNotification = bot.enableNotification;
      _customBaseURL.text = bot.customBaseURL;
      _payload = bot.payload;
    });
  }

  Future<void> _save() async {
    final id = _botId.text.trim();
    if (id.isEmpty) {
      showErrorAlert(context, 'Bot ID cannot be empty');
      return;
    }
    await Storage.saveBot(Bot(
      id: id,
      name: _name.text.trim(),
      ymAuthToken: _ymAuthToken.text.trim(),
      customBaseURL: _customBaseURL.text.trim(),
      apiKey: _apiKey.text.trim(),
      version: _version,
      enableSpeech: _enableSpeech,
      enableLiteVersion: _enableLiteVersion,
      enableNotification: _enableNotification,
      date: DateTime.now(),
      payload: _payload,
      activationMode: _activationMode,
      initialUserMessage: _initialUserMessage.text.trim(),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openPayload() async {
    final botId = _botId.text.trim();
    if (botId.isEmpty) {
      showInfoAlert(context, 'Enter the bot id first');
      return;
    }
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => PayloadScreen(botId: botId, payload: _payload),
      ),
    );
    if (result != null) setState(() => _payload = result);
  }

  Widget _input(TextEditingController controller,
      {String? hint, bool enabled = true, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      autocorrect: false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        filled: !enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isV3 = _version == 3;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Add Profile'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          FieldRow(
            label: 'Bot Id',
            child: _input(_botId, hint: 'x0123456789', enabled: !_isEditing),
          ),
          FieldRow(
            label: 'Name',
            child: _input(_name, hint: 'Label for this profile'),
          ),
          FieldRow(
            label: 'Version',
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('v1')),
                ButtonSegment(value: 2, label: Text('v2')),
                ButtonSegment(value: 3, label: Text('v3')),
              ],
              selected: {_version},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _version = s.first),
            ),
          ),
          if (isV3) ...[
            FieldRow(
              label: 'Activation Mode',
              child: SegmentedButton<ActivationMode>(
                segments: const [
                  ButtonSegment(value: ActivationMode.chat, label: Text('chat')),
                  ButtonSegment(
                      value: ActivationMode.voice, label: Text('voice')),
                ],
                selected: {_activationMode},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    setState(() => _activationMode = s.first),
              ),
            ),
            FieldRow(
              label: 'Initial Message',
              child: _input(_initialUserMessage, hint: 'Optional'),
            ),
          ] else ...[
            SwitchListTile(
              title: const Text('Enable Speech'),
              value: _enableSpeech,
              onChanged: (v) => setState(() => _enableSpeech = v),
            ),
            SwitchListTile(
              title: const Text('Use Lite Version'),
              value: _enableLiteVersion,
              onChanged: (v) => setState(() => _enableLiteVersion = v),
            ),
          ],
          FieldRow(
            label: 'YMAuthToken',
            child: _input(_ymAuthToken, hint: 'Optional'),
          ),
          FieldRow(
            label: 'Api Key',
            child: _input(_apiKey, hint: 'Needed for Register / Unlink device'),
          ),
          SwitchListTile(
            title: const Text('Push Notification'),
            value: _enableNotification,
            onChanged: (v) => setState(() => _enableNotification = v),
          ),
          FieldRow(
            label: 'Custom Base URL',
            child: _input(_customBaseURL,
                hint: 'Leave empty for the default region',
                keyboardType: TextInputType.url),
          ),
          ListTile(
            title: const Text('Payload'),
            subtitle: Text(
              _payload.isEmpty ? 'Tap to add a JSON payload' : _payload,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openPayload,
          ),
        ],
      ),
    );
  }
}
