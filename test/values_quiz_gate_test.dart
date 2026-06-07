import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/core/services/values_service.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_gate.dart';

void main() {
  group('isValuesQuizPending', () {
    test('completed quiz status is not pending', () {
      expect(
        isValuesQuizPending(
          quizStatus: const ValuesQuizStatus(status: 'completed'),
        ),
        isFalse,
      );
    });

    test('completed registration status is not pending when quiz status unknown', () {
      expect(
        isValuesQuizPending(registrationValuesQuizStatus: 'completed'),
        isFalse,
      );
    });

    test('completed dedicated cache beats pending registration cache', () {
      expect(
        isValuesQuizPending(
          registrationValuesQuizStatus: 'pending',
          cachedValuesQuizStatus: 'completed',
        ),
        isFalse,
      );
    });

    test('null cache alone does not override completed registration', () {
      expect(
        isValuesQuizPending(
          registrationValuesQuizStatus: 'skipped',
          cachedValuesQuizStatus: null,
        ),
        isFalse,
      );
    });

    test('pending when all signals unknown', () {
      expect(isValuesQuizPending(), isTrue);
    });
  });
}
