import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ymchat_flutter/ymchat_flutter.dart';

import 'models/bot.dart';
import 'storage.dart';

/// Bridges saved profiles to the ymchat_flutter plugin.
class Chatbot {
  /// Equivalent of `Bot.toYMConfig` in the iOS tester app. setBotId() creates
  /// a fresh config natively on both platforms, so it must be called first.
  static Future<void> _applyConfig(Bot bot) async {
    await YmChat.setBotId(bot.id);
    await YmChat.setVersion(bot.version);
    await YmChat.showCloseButton(true);

    if (bot.version == 3) {
      await YmChat.setActivationMode(bot.activationMode.name);
      if (bot.initialUserMessage.isNotEmpty) {
        await YmChat.setInitialUserMessage(bot.initialUserMessage);
      }
    } else {
      await YmChat.setEnableSpeech(bot.enableSpeech);
      await YmChat.useLiteVersion(bot.enableLiteVersion);
    }

    if (bot.ymAuthToken.isNotEmpty) {
      await YmChat.setAuthenticationToken(bot.ymAuthToken);
    }
    if (bot.enableNotification) {
      await YmChat.setDeviceToken(await Storage.getFcmToken());
    }
    if (bot.customBaseURL.isNotEmpty) {
      await YmChat.setCustomURL(bot.customBaseURL);
    }
    // Always set the payload: on Android the previous bot's payload otherwise
    // carries over into the next config.
    await YmChat.setPayload(bot.payloadMap);
  }

  static Future<void> startBot(Bot bot) async {
    await _applyConfig(bot);
    await YmChat.startChatbot();
  }

  /// Quick Start: bot id only, everything else at SDK defaults.
  static Future<void> quickStart(String botId) async {
    await YmChat.setBotId(botId);
    await YmChat.setPayload({});
    await YmChat.showCloseButton(true);
    await YmChat.startChatbot();
  }

  static Future<void> registerDevice(Bot bot) async {
    await _applyConfig(bot);
    final completer = Completer<void>();
    await YmChat.registerDevice(
      bot.apiKey,
      (_) => completer.complete(),
      (error) => completer.completeError(error.toString()),
    );
    return completer.future;
  }

  /// The plugin unlinks the device token of the current config, so the
  /// profile (with its FCM token) is applied first.
  static Future<void> unlinkDeviceToken(Bot bot) async {
    await _applyConfig(bot);
    final completer = Completer<void>();
    await YmChat.unLinkDeviceToken(
      bot.apiKey,
      () => completer.complete(),
      (error) => completer.completeError(error.toString()),
    );
    return completer.future;
  }

  // Native SDK events, delivered on the plugin's event channels.
  static Stream<dynamic> get events =>
      const EventChannel('YMChatEvent').receiveBroadcastStream();
  static Stream<dynamic> get closeEvents =>
      const EventChannel('YMBotCloseEvent').receiveBroadcastStream();
  static Stream<dynamic> get loadFailedEvents =>
      const EventChannel('YMBotLoadFailedEvent').receiveBroadcastStream();
}
