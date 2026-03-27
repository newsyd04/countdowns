import '../../domain/usecases/countdown_usecases.dart';

/// Immutable state for the countdowns feature.
///
/// Uses a sealed-class-like pattern (via named constructors)
/// for exhaustive state handling in the UI layer.
abstract class CountdownsState {
  const CountdownsState();

  const factory CountdownsState.loading() = CountdownsLoading;
  const factory CountdownsState.loaded({required CountdownSections sections}) =
      CountdownsLoaded;
  const factory CountdownsState.error(String message) = CountdownsError;

  /// Pattern match on state variants.
  T when<T>({
    required T Function() loading,
    required T Function(CountdownSections sections) loaded,
    required T Function(String message) error,
  }) {
    if (this is CountdownsLoading) return loading();
    if (this is CountdownsLoaded) {
      return loaded((this as CountdownsLoaded).sections);
    }
    if (this is CountdownsError) {
      return error((this as CountdownsError).message);
    }
    throw StateError('Unknown state: $runtimeType');
  }
}

class CountdownsLoading extends CountdownsState {
  const CountdownsLoading();
}

class CountdownsLoaded extends CountdownsState {
  final CountdownSections sections;

  const CountdownsLoaded({required this.sections});
}

class CountdownsError extends CountdownsState {
  final String message;

  const CountdownsError(this.message);
}
