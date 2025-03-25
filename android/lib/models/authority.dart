// authority.dart
class Authority {
  int? id;
  String? authority;

  Authority({this.id, this.authority});

  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      id: json['id'],
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['authority'] = authority;
    return data;
  }
}
