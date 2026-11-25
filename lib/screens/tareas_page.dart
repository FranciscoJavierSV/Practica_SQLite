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

  // Actualiza si la tarea está pendiente o completada.
  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await _baseDatos.cambiarEstado(tarea.id, completada);
      await _cargarTareas();
    } catch (_) {
      _pendiente('No se pudo cambiar el estado');
    }
  }

  // Abre un cuadro para escribir el nuevo título de la tarea.
  Future<void> _editarTarea(Tarea tarea) async {
    final controlador = TextEditingController(text: tarea.titulo);

    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, controlador.text);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    controlador.dispose();

    if (nuevoTitulo == null) return;

    final titulo = nuevoTitulo.trim();
    if (titulo.isEmpty) {
      _pendiente('El título no puede estar vacío');
      return;
    }

    try {
      await _baseDatos.editarTitulo(tarea.id, titulo);
      await _cargarTareas();
    } catch (_) {
      _pendiente('No se pudo editar la tarea');
    }
  }

  // Elimina la tarea seleccionada usando su identificador.
  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await _baseDatos.eliminarTarea(tarea.id);
      await _cargarTareas();
      _pendiente('Tarea eliminada');
    } catch (_) {
      _pendiente('No se pudo eliminar la tarea');
    }
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
