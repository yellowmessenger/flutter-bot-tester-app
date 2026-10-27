import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/bot.dart';

/// On-device profile storage, the equivalent of `UserDefaults` in the iOS
/// tester app. Profiles are stored under `bot-<botId>`.
class Storage {
  static const _botPrefix = 'bot-';
  static const _fcmTokenKey = 'fcmToken';

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<List<Bot>> getBotList() async {
    final all = await _prefs.getAll();
    final bots = <Bot>[];
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_botPrefix) || entry.value is! String) continue;
      try {
        bots.add(Bot.fromJson(jsonDecode(entry.value as String)));
      } on FormatException {
        // Skip a corrupt entry rather than breaking the whole list.
      }
    }
    bots.sort((a, b) => b.date.compareTo(a.date));
    return bots;
  }

  static Future<Bot?> getBot(String botId) async {
    final value = await _prefs.getString('$_botPrefix$botId');
    return value == null ? null : Bot.fromJson(jsonDecode(value));
  }

  static Future<void> saveBot(Bot bot) =>
      _prefs.setString('$_botPrefix${bot.id}', jsonEncode(bot.toJson()));

  static Future<void> deleteBot(String botId) =>
      _prefs.remove('$_botPrefix$botId');

  static Future<String> getFcmToken() async =>
      await _prefs.getString(_fcmTokenKey) ?? '';

  static Future<void> setFcmToken(String token) =>
      _prefs.setString(_fcmTokenKey, token);
}
