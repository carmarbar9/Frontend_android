class Categoria {
  final String id;
  final String name;
  final String pertenece;
  final String negocioId; // 👈 Añadido para saber a qué negocio pertenece

  Categoria({
    required this.id,
    required this.name,
    required this.pertenece,
    required this.negocioId,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      pertenece: json['pertenece'] ?? '',
      negocioId: json['negocio']?['id']?.toString() ?? '', // 👈 Lo extraemos del JSON anidado
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pertenece': pertenece,
      'negocio': {
        'id': negocioId,
      },
    };
  }
}
