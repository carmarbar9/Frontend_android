enum SubscripcionStatus { ACTIVE, CANCELED, PAST_DUE, UNPAID }

enum SubscripcionType { FREE, PREMIUM, PILOT }

class Subscripcion {
  final SubscripcionType planType;
  final SubscripcionStatus status;
  final DateTime expirationDate;
  final DateTime nextBillingDate;
  final bool isActive;
  final bool isPremium;

  Subscripcion({
    required this.planType,
    required this.status,
    required this.expirationDate,
    required this.nextBillingDate,
    required this.isActive,
    required this.isPremium,
  });

  factory Subscripcion.fromJson(Map<String, dynamic> json) {
    return Subscripcion(
      planType: SubscripcionType.values.firstWhere(
          (e) => e.toString().split('.').last == json['planType']),
      status: SubscripcionStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status']),
      expirationDate: DateTime.parse(json['expirationDate']),
      nextBillingDate: DateTime.parse(json['nextBillingDate']),
      isActive: json['isActive'],
      isPremium: json['isPremium'],
    );
  }
}
