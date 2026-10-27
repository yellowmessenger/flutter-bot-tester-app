import 'dart:convert';

enum ActivationMode { chat, voice }

/// A saved bot profile. Mirrors `struct Bot` in the iOS tester app
/// (BotModel.swift) and uses the same JSON keys as the React Native app.
class Bot {
  const Bot({
    required this.id,
    this.name = '',
    this.ymAuthToken = '',
    this.customBaseURL = '',
    this.apiKey = '',
    this.version = 1,
    this.enableSpeech = false,
    this.enableLiteVersion = false,
    this.enableNotification = false,
    required this.date,
    this.payload = '',
    this.activationMode = ActivationMode.chat,
    this.initialUserMessage = '',
  });

  final String id;
  final String name;
  final String ymAuthToken;
  final String customBaseURL;
  final String apiKey;
  final int version; // 1, 2 or 3
  final bool enableSpeech;
  final bool enableLiteVersion;
  final bool enableNotification;
  final DateTime date; // used to sort the profile list, newest first
  final String payload; // raw JSON text, validated in the payload editor
  final ActivationMode activationMode;
  final String initialUserMessage;

  Bot copyWith({String? payload}) => Bot(
        id: id,
        name: name,
        ymAuthToken: ymAuthToken,
        customBaseURL: customBaseURL,
        apiKey: apiKey,
        version: version,
        enableSpeech: enableSpeech,
        enableLiteVersion: enableLiteVersion,
        enableNotification: enableNotification,
        date: date,
        payload: payload ?? this.payload,
        activationMode: activationMode,
        initialUserMessage: initialUserMessage,
      );

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'ymAuthToken': ymAuthToken,
        'customBaseURL': customBaseURL,
        'apiKey': apiKey,
        'version': version,
        'enableSpeech': enableSpeech,
        'enableLiteVersion': enableLiteVersion,
        'enableNotification': enableNotification,
        'date': date.millisecondsSinceEpoch,
        'payload': payload,
        'activationMode': activationMode.name,
        'initialUserMessage': initialUserMessage,
      };

  factory Bot.fromJson(Map<String, dynamic> json) => Bot(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        ymAuthToken: json['ymAuthToken'] as String? ?? '',
        customBaseURL: json['customBaseURL'] as String? ?? '',
        apiKey: json['apiKey'] as String? ?? '',
        version: json['version'] as int? ?? 1,
        enableSpeech: json['enableSpeech'] as bool? ?? false,
        enableLiteVersion: json['enableLiteVersion'] as bool? ?? false,
        enableNotification: json['enableNotification'] as bool? ?? false,
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int? ?? 0),
        payload: json['payload'] as String? ?? '',
        activationMode: json['activationMode'] == 'voice'
            ? ActivationMode.voice
            : ActivationMode.chat,
        initialUserMessage: json['initialUserMessage'] as String? ?? '',
      );

  /// The payload as a map for the SDK. Empty when no payload is set.
  /// Top-level nulls are dropped: the plugin's setPayload takes
  /// `Map<String, Object>`.
  Map<String, Object> get payloadMap {
    if (payload.trim().isEmpty) return {};
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    return {
      for (final e in decoded.entries)
        if (e.value != null) e.key: e.value as Object,
    };
  }
}

/// A payload must be empty or a JSON object.
bool isValidPayload(String text) {
  if (text.trim().isEmpty) return true;
  try {
    return jsonDecode(text) is Map;
  } on FormatException {
    return false;
  }
}
