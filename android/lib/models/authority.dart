class Authority {
  int? id;
  String? authority;

  Authority({
    this.id,
    this.authority,
  });

  /// Crea una instancia de Authority a partir de un JSON.
  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      id: json['id'],
      authority: json['authority'],
    );
  }

  /// Convierte la instancia a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authority': authority,
    };
  }
}
