import 'package:flutter_test/flutter_test.dart';
import 'package:yellow_bot_tester/models/bot.dart';

void main() {
  group('isValidPayload', () {
    test('accepts empty and JSON objects', () {
      expect(isValidPayload(''), isTrue);
      expect(isValidPayload('  '), isTrue);
      expect(isValidPayload('{"name": "Asha", "age": 30}'), isTrue);
    });

    test('rejects arrays, scalars and broken JSON', () {
      expect(isValidPayload('[1, 2]'), isFalse);
      expect(isValidPayload('"text"'), isFalse);
      expect(isValidPayload('{"name": }'), isFalse);
    });
  });

  group('Bot', () {
    final bot = Bot(
      id: 'x123',
      name: 'Test',
      version: 3,
      activationMode: ActivationMode.voice,
      date: DateTime.fromMillisecondsSinceEpoch(1000),
      payload: '{"city": "Pune", "skip": null}',
    );

    test('round-trips through JSON', () {
      final copy = Bot.fromJson(bot.toJson());
      expect(copy.id, 'x123');
      expect(copy.version, 3);
      expect(copy.activationMode, ActivationMode.voice);
      expect(copy.date, bot.date);
      expect(copy.payload, bot.payload);
    });

    test('payloadMap drops nulls and is empty without a payload', () {
      expect(bot.payloadMap, {'city': 'Pune'});
      expect(bot.copyWith(payload: '').payloadMap, isEmpty);
    });
  });
}
