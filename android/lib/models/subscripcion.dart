enum SubscripcionStatus { ACTIVE, CANCELED, PAST_DUE, UNPAID }

enum SubscripcionType { FREE, PREMIUM, PILOT }

class Subscripcion {
  final int id;
  final SubscripcionType type;
  final SubscripcionStatus status;
  final String startDate;
  final String endDate;
  final String nextBillingDate;

  Subscripcion({
    required this.id,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.nextBillingDate,
  });

  factory Subscripcion.fromJson(Map<String, dynamic> json) {
    return Subscripcion(
      id: json['id'],
      type: SubscripcionType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type']),
      status: SubscripcionStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status']),
      startDate: json['startDate'],
      endDate: json['endDate'],
      nextBillingDate: json['nextBillingDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startDate': startDate,
      'endDate': endDate,
      'nextBillingDate': nextBillingDate,
    };
  }

  bool get isActive => status == SubscripcionStatus.ACTIVE;

  bool get isPremium =>
      type == SubscripcionType.PREMIUM && isActive;
}
