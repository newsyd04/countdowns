import 'dart:async';

import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/countdown_model.dart';

/// Local data source using Hive for countdown persistence.
///
/// This is the only class that knows about Hive directly.
/// All Hive operations are encapsulated here.
class CountdownLocalDataSource {
  Box<CountdownModel>? _box;
  final _streamController =
      StreamController<List<CountdownModel>>.broadcast();

  /// Initialize the Hive box. Must be called before any other method.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CountdownModelAdapter());
    }
    _box = await Hive.openBox<CountdownModel>(AppConstants.hiveBoxName);
  }

  Box<CountdownModel> get _safeBox {
    if (_box == null) {
      throw StateError(
        'CountdownLocalDataSource not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  /// Get all countdown models from storage.
  List<CountdownModel> getAll() {
    return _safeBox.values.toList();
  }

  /// Get a single countdown by ID.
  CountdownModel? getById(String id) {
    try {
      return _safeBox.values.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save a countdown model to storage.
  Future<void> save(CountdownModel model) async {
    await _safeBox.put(model.id, model);
    _notifyListeners();
  }

  /// Delete a countdown by ID.
  Future<void> delete(String id) async {
    await _safeBox.delete(id);
    _notifyListeners();
  }

  /// Save multiple models at once (for reordering).
  Future<void> saveAll(List<CountdownModel> models) async {
    final map = {for (final m in models) m.id: m};
    await _safeBox.putAll(map);
    _notifyListeners();
  }

  /// Watch for changes as a stream.
  Stream<List<CountdownModel>> watchAll() {
    // Emit current state immediately, then emit on changes
    return _streamController.stream;
  }

  void _notifyListeners() {
    _streamController.add(getAll());
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await _streamController.close();
    await _box?.close();
  }
}
