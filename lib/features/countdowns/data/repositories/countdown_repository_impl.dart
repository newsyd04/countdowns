import '../../domain/entities/countdown.dart';
import '../../domain/repositories/countdown_repository.dart';
import '../datasources/countdown_local_datasource.dart';
import '../models/countdown_model.dart';

/// Concrete implementation of CountdownRepository using Hive.
///
/// Handles the mapping between domain entities and data models,
/// and implements sorting/filtering logic.
class CountdownRepositoryImpl implements CountdownRepository {
  final CountdownLocalDataSource _dataSource;

  CountdownRepositoryImpl(this._dataSource);

  @override
  Future<List<Countdown>> getAll() async {
    final models = _dataSource.getAll();
    final entities = models.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  @override
  Future<Countdown?> getById(String id) async {
    final model = _dataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Countdown>> getUpcoming() async {
    final all = await getAll();
    return all.where((c) => !c.isPast).toList()
      ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
  }

  @override
  Future<List<Countdown>> getPast() async {
    final all = await getAll();
    return all.where((c) => c.isPast).toList()
      ..sort((a, b) => b.targetDate.compareTo(a.targetDate));
  }

  @override
  Future<Countdown> create(Countdown countdown) async {
    // Assign sort order: new items go to the top of upcoming
    final all = _dataSource.getAll();
    final minOrder = all.isEmpty
        ? 0
        : all.map((m) => m.toEntity().sortOrder).reduce(
              (a, b) => a < b ? a : b,
            );
    final ordered = countdown.copyWith(sortOrder: minOrder - 1);

    final model = CountdownModel.fromEntity(ordered);
    await _dataSource.save(model);
    return ordered;
  }

  @override
  Future<Countdown> update(Countdown countdown) async {
    final model = CountdownModel.fromEntity(countdown);
    await _dataSource.save(model);
    return countdown;
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final models = <CountdownModel>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final existing = _dataSource.getById(orderedIds[i]);
      if (existing != null) {
        existing.sortOrder = i;
        models.add(existing);
      }
    }
    await _dataSource.saveAll(models);
  }

  @override
  Stream<List<Countdown>> watchAll() {
    return _dataSource.watchAll().map(
          (models) => models.map((m) => m.toEntity()).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
        );
  }
}
