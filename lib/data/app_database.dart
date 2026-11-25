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
  // Aquí se abre la base. En el navegador también se indican los archivos necesarios.
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'gestor_tareas',
                // Estos archivos permiten usar SQLite cuando la app se ejecuta en Chrome.
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.dart.js'),
                ),
              ),
        );

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

  // Cambia el título de una tarea buscando su identificador.
  Future<void> editarTitulo(int id, String nuevoTitulo) {
    return (update(tareas)..where((fila) => fila.id.equals(id))).write(
      TareasCompanion(titulo: Value(nuevoTitulo)),
    );
  }

  // Actualiza si la tarea está pendiente o completada.
  Future<void> cambiarEstado(int id, bool completada) {
    return (update(tareas)..where((fila) => fila.id.equals(id))).write(
      TareasCompanion(completada: Value(completada)),
    );
  }

  // Elimina solo la tarea que tenga ese identificador.
  Future<void> eliminarTarea(int id) {
    return (delete(tareas)..where((fila) => fila.id.equals(id))).go();
  }
}
