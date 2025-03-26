class Categoria {
  final String id;
  final String name;
  final String pertenece; // 👈 Añadimos este campo

  Categoria({
    required this.id,
    required this.name,
    required this.pertenece,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      pertenece: json['pertenece'] ?? '', // 👈 Aquí lo traes del backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pertenece': pertenece,
    };
  }
}
