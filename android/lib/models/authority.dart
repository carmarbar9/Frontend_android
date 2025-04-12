class Authority {
  final int id;
  final String authority;

  Authority({
    required this.id,
    required this.authority,
  });

  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      id: json['id'],
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authority': authority,
    };
  }
}
