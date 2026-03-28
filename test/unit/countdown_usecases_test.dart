import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:countdowns/core/utils/date_utils.dart';
import 'package:countdowns/features/countdowns/domain/entities/countdown.dart';
import 'package:countdowns/features/countdowns/domain/repositories/countdown_repository.dart';
import 'package:countdowns/features/countdowns/domain/usecases/countdown_usecases.dart';

class MockCountdownRepository extends Mock implements CountdownRepository {}

void main() {
  late MockCountdownRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(Countdown(
      id: 'fallback',
      title: 'Fallback',
      targetDate: DateTime(2030),
      emoji: '',
      colorIndex: 0,
      createdAt: DateTime(2030),
      updatedAt: DateTime(2030),
    ));
  });

  setUp(() {
    mockRepository = MockCountdownRepository();
  });

  Countdown createTestCountdown({
    String? id,
    String? title,
    DateTime? targetDate,
    RecurrenceType recurrence = RecurrenceType.none,
  }) {
    return Countdown(
      id: id ?? 'test-id',
      title: title ?? 'Test',
      targetDate: targetDate ?? DateTime.now().add(const Duration(days: 10)),
      emoji: '\u{1F389}',
      colorIndex: 0,
      recurrence: recurrence,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('GetCountdownsUseCase', () {
    test('separates upcoming and past countdowns', () async {
      final upcoming = createTestCountdown(
        id: '1',
        targetDate: DateTime.now().add(const Duration(days: 5)),
      );
      final past = createTestCountdown(
        id: '2',
        targetDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [upcoming, past]);

      final useCase = GetCountdownsUseCase(mockRepository);
      final result = await useCase();

      expect(result.upcoming.length, 1);
      expect(result.past.length, 1);
      expect(result.upcoming.first.id, '1');
      expect(result.past.first.id, '2');
    });

    test('sorts upcoming by soonest first', () async {
      final soon = createTestCountdown(
        id: '1',
        targetDate: DateTime.now().add(const Duration(days: 2)),
      );
      final later = createTestCountdown(
        id: '2',
        targetDate: DateTime.now().add(const Duration(days: 10)),
      );

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [later, soon]);

      final useCase = GetCountdownsUseCase(mockRepository);
      final result = await useCase();

      expect(result.upcoming.first.id, '1');
      expect(result.upcoming.last.id, '2');
    });

    test('returns empty sections when no countdowns', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => []);

      final useCase = GetCountdownsUseCase(mockRepository);
      final result = await useCase();

      expect(result.isEmpty, true);
      expect(result.totalCount, 0);
    });
  });

  group('CreateCountdownUseCase', () {
    test('creates countdown with correct defaults', () async {
      when(() => mockRepository.create(any())).thenAnswer((invocation) async {
        return invocation.positionalArguments[0] as Countdown;
      });

      final useCase = CreateCountdownUseCase(mockRepository);
      final result = await useCase(
        title: 'Birthday',
        targetDate: DateTime(2025, 12, 25),
      );

      expect(result.title, 'Birthday');
      expect(result.emoji, '\u{1F389}'); // Default emoji
      expect(result.notificationsEnabled, true);
      verify(() => mockRepository.create(any())).called(1);
    });
  });

  group('SuggestDateUseCase', () {
    test('suggests next year for past dates', () {
      final useCase = SuggestDateUseCase();
      final pastDate = DateTime.now().subtract(const Duration(days: 30));
      final result = useCase(pastDate);

      expect(result.hasSuggestion, true);
      expect(result.suggestedDate.year, pastDate.year + 1);
      expect(result.message, isNotNull);
    });

    test('no suggestion for future dates', () {
      final useCase = SuggestDateUseCase();
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final result = useCase(futureDate);

      expect(result.hasSuggestion, false);
    });
  });

  group('DeleteCountdownUseCase', () {
    test('calls repository delete', () async {
      when(() => mockRepository.delete(any())).thenAnswer((_) async {});

      final useCase = DeleteCountdownUseCase(mockRepository);
      await useCase('test-id');

      verify(() => mockRepository.delete('test-id')).called(1);
    });
  });
}
