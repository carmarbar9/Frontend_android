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
    try {
      return Subscripcion(
        planType: SubscripcionType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => SubscripcionType.FREE,
        ),
        status: SubscripcionStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => SubscripcionStatus.UNPAID,
        ),
        expirationDate:
            json['end_date'] != null
                ? DateTime.parse(json['end_date'])
                : DateTime.now().add(const Duration(days: 30)),
        nextBillingDate:
            json['start_date'] != null
                ? DateTime.parse(json['start_date'])
                : DateTime.now(),
        isActive: json['active'] ?? false,
        isPremium: json['premium'] ?? false,
      );
    } catch (e) {
      print('❌ Error al parsear Subscripcion: $e');
      return Subscripcion(
        planType: SubscripcionType.FREE,
        status: SubscripcionStatus.UNPAID,
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        nextBillingDate: DateTime.now(),
        isActive: false,
        isPremium: false,
      );
    }
  }
}
