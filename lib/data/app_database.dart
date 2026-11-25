import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Esta es la tabla donde se guardan las tareas.
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  BoolColumn get completada =>
      boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  // Aquí se abre la base de datos. Drift elige el lugar adecuado para guardarla.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'gestor_tareas'));

  @override
  int get schemaVersion => 1;

  // Cuando se agrega una tarea, primero se guarda su título en SQLite.
  Future<int> agregarTarea(String titulo) {
    return into(tareas).insert(TareasCompanion.insert(titulo: titulo));
  }

  // Esto devuelve las tareas que ya están guardadas, desde la más antigua.
  Future<List<Tarea>> consultarTareas() {
    return (select(tareas)
          ..orderBy([(tabla) => OrderingTerm.asc(tabla.id)]))
        .get();
  }
}
