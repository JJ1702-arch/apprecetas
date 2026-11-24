class Receta {
  final int id;
  final String nombre;
  final String descripcion;
  final List<String> ingredientes;
  final List<String> instrucciones;
  final int tiempoPreparacion;
  final int tiempoCoccion;
  final int porciones;
  final int calorias;
  final String imagen;
  final double calificacion;
  final String dificultad;
  final String cocina;

  const Receta({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ingredientes,
    required this.instrucciones,
    required this.tiempoPreparacion,
    required this.tiempoCoccion,
    required this.porciones,
    required this.calorias,
    required this.imagen,
    required this.calificacion,
    this.dificultad = 'Easy',
    this.cocina = 'Internacional',
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    final ingredientes = json['ingredients'];
    final instrucciones = json['instructions'];

    return Receta(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['name'] is String ? json['name'] as String : 'Sin nombre',
      descripcion: (json['description'] as String?) ?? '',
      ingredientes: ingredientes is List
          ? ingredientes.map((item) => item.toString()).toList()
          : const [],
      instrucciones: instrucciones is List
          ? instrucciones.map((item) => item.toString()).toList()
          : const [],
      tiempoPreparacion: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      tiempoCoccion: (json['cookTimeMinutes'] as num?)?.toInt() ??
          (json['cookingMinutes'] as num?)?.toInt() ??
          0,
      porciones: (json['servings'] as num?)?.toInt() ?? 1,
      calorias: (json['caloriesPerServing'] as num?)?.toInt() ?? 0,
      imagen: (json['image'] as String?) ?? '',
      calificacion: ((json['rating'] ?? json['calificacion']) as num?)?.toDouble() ?? 0,
      dificultad: (json['difficulty'] as String?) ?? 'Easy',
      cocina: (json['cuisine'] as String?) ?? 'Internacional',
    );
  }

  int get tiempoTotal => tiempoPreparacion + tiempoCoccion;
  int get totalTime => tiempoTotal;
  String get imagenUrl => imagen;
}
