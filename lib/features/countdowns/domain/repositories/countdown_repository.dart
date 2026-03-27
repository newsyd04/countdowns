import '../entities/countdown.dart';

/// Abstract repository contract for countdown persistence.
///
/// The domain layer defines what operations are needed;
/// the data layer decides how they're implemented.
abstract class CountdownRepository {
  /// Get all countdowns, ordered by sort order.
  Future<List<Countdown>> getAll();

  /// Get a single countdown by ID.
  Future<Countdown?> getById(String id);

  /// Get all upcoming countdowns (including today), sorted soonest first.
  Future<List<Countdown>> getUpcoming();

  /// Get all past countdowns, sorted most recent first.
  Future<List<Countdown>> getPast();

  /// Create a new countdown. Returns the created entity.
  Future<Countdown> create(Countdown countdown);

  /// Update an existing countdown. Returns the updated entity.
  Future<Countdown> update(Countdown countdown);

  /// Delete a countdown by ID.
  Future<void> delete(String id);

  /// Reorder countdowns. Takes a list of IDs in the new order.
  Future<void> reorder(List<String> orderedIds);

  /// Watch all countdowns as a stream (for reactive updates).
  Stream<List<Countdown>> watchAll();
}
