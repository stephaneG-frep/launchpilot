import 'dart:async';

import 'package:drift/drift.dart';

/// Recalcule [load] à chaque modification de [tables]. Les chargements sont
/// enchaînés : les résultats arrivent toujours dans l'ordre.
Stream<T> watchTables<T>(
  DatabaseConnectionUser db,
  List<TableInfo> tables,
  Future<T> Function() load,
) {
  late final StreamController<T> controller;
  StreamSubscription<Set<TableUpdate>>? updates;
  var chain = Future<void>.value();

  void reload() {
    chain = chain.then((_) async {
      if (controller.isClosed) return;
      try {
        final value = await load();
        if (!controller.isClosed) controller.add(value);
      } catch (e, s) {
        if (!controller.isClosed) controller.addError(e, s);
      }
    });
  }

  controller = StreamController<T>(
    onListen: () {
      reload();
      updates = db
          .tableUpdates(TableUpdateQuery.onAllTables(tables))
          .listen((_) => reload());
    },
    onCancel: () async {
      await updates?.cancel();
      await controller.close();
    },
  );
  return controller.stream;
}
