# Capa de datos pendiente

La base NO incluye SQLite implementado. Investiga cómo crear una tabla de tareas
con Drift y cómo abrir una base persistente en Android, iOS, Windows, Linux,
macOS y web. Puedes decidir los nombres de los archivos y las clases.

No coloques consultas SQL dentro de build(). Documenta tus decisiones en el reporte.

de acuerdo a lo que encontre  en la investigacion 
elegí Drift con SQLite porque permite guardar las tareas localmente y usar el mismo código en varias plataformas. La memoria no sirve para persistencia: al cerrar la app, la lista podría desaparecer.

La tabla Tareas contiene:

- id: entero autoincremental.
- titulo: texto.
- completada: booleano.

`app_database.dart` abre la base y contiene las operaciones de guardar y consultar.
`app_database.g.dart` fue generado con build_runner y no se modifica manualmente este fue el codigo que me 
falto y no funciono al inicio y tuve que pedir ayuda
debido a que solo me indicaron como instalar dependencias pero no este paso extra.

Las tareas siguen guardadas al cerrar y volver a abrir la app incluso en crome ya que se reparo el problemas que le faltaban en el projecto.