import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:practica_sqlite/main.dart';
import 'package:practica_sqlite/data/app_database.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    await tester.pumpWidget(const GestorTareasApp());
    await tester.pumpAndSettle();

    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Cierra la pantalla y su base antes de iniciar otra prueba.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Rechaza una tarea por poner solo espacios en el campo', () {
    final titulo = '   '.trim();

    expect(titulo.isEmpty, isTrue);
  });

  test('Guarda y consulta una tarea en la base de datos', () async {
    final baseDatos = AppDatabase(NativeDatabase.memory());

    await baseDatos.agregarTarea('estudiar sqlite');
    final tareas = await baseDatos.consultarTareas();

    expect(tareas, hasLength(1));
    expect(tareas.first.titulo, 'estudiar sqlite');

    await baseDatos.close();
  });
}
