import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../data/app_database.dart' hide Tarea;

// Esta pantalla permite mostrar las tareas y guardar nuevas.
class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();
  final AppDatabase _baseDatos = AppDatabase();

  List<Tarea> _tareas = [];

  @override
  void initState() {
    super.initState();
    // Cuando se abre la pantalla, se cargan las tareas que quedaron guardadas.
    _cargarTareas();
  }

  // Busca las tareas en SQLite y las pone en la lista de la pantalla.
  Future<void> _cargarTareas() async {
    try {
      final registros = await _baseDatos.consultarTareas();
      final tareas = registros
          .map((registro) => Tarea(
                id: registro.id,
                titulo: registro.titulo,
                completada: registro.completada,
              ))
          .toList();

      if (!mounted) return;
      setState(() => _tareas = tareas);
    } catch (_) {
      if (!mounted) return;
      _pendiente('No se pudieron consultar las tareas');
    }
  }

  // Si el título tiene texto, la tarea se guarda y vuelve a aparecer en la lista.
  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      _pendiente('El título no puede estar vacío');
      return;
    }

    try {
      await _baseDatos.agregarTarea(titulo);
      _tituloController.clear();
      await _cargarTareas();
    } catch (_) {
      _pendiente('No se pudo guardar la tarea');
    }
  }

  void _alternarCompletada(Tarea tarea, bool completada) {
    _pendiente('Implementar actualización de tarea');
  }

  void _editarTarea(Tarea tarea) {
    _pendiente('Implementar edición de título');
  }

  void _eliminarTarea(Tarea tarea) {
    _pendiente('Implementar eliminación de tarea');
  }

  void _pendiente(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _baseDatos.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: _tareas.isEmpty
                  ? const Center(child: Text('Todavía no hay tareas guardadas'))
                  : ListView.builder(
                      itemCount: _tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = _tareas[index];
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completada,
                              onChanged: (valor) {
                                if (valor != null) {
                                  _alternarCompletada(tarea, valor);
                                }
                              },
                            ),
                            title: Text(tarea.titulo),
                            subtitle: Text('ID: ${tarea.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarTarea(tarea),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
