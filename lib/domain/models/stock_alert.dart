
/// How urgent a stock alert is. The order of the values is the display order:
/// critical first, low last.
enum Severity { critical, high, medium, low }

/// One stock alert for one branch, as sent by Nour head office.
final class StockAlert {
  const StockAlert({
    required this.id,
    required this.medicineNameEn,
    required this.medicineNameAr,
    required this.severity,
    required this.daysOfCover,
    required this.branchCode,
    this.acknowledged = false,
  });

  final String id;
  final String medicineNameEn;
  final String medicineNameAr;
  final Severity severity;
  final double daysOfCover;
  final String branchCode;
  final bool acknowledged;

  factory StockAlert.fromJson(Map<String, Object?> json) {
    String readRequiredString(String key) {
      final value = json[key];

      if (value is! String || value.trim().isEmpty) {
        throw FormatException(
          'Invalid or missing "$key": expected a non-empty string.',
        );
      }

      return value;
    }

    final id = readRequiredString('id');
    final medicineNameEn = readRequiredString('medicineNameEn');
    final medicineNameAr = readRequiredString('medicineNameAr');
    final branchCode = readRequiredString('branchCode');

    final severityValue = json['severity'];

    if (severityValue is! String) {
      throw const FormatException(
        'Invalid or missing "severity": expected a string.',
      );
    }

    final Severity severity;
    switch (severityValue.toLowerCase()) {
      case 'critical':
        severity = Severity.critical;
        break;
      case 'high':
        severity = Severity.high;
        break;
      case 'medium':
        severity = Severity.medium;
        break;
      case 'low':
        severity = Severity.low;
        break;
      default:
        throw FormatException('Unknown severity: $severityValue');
    }

    final daysValue = json['daysOfCover'];

    if (daysValue is! num ||
        !daysValue.toDouble().isFinite ||
        daysValue < 0) {
      throw const FormatException(
        'Invalid or missing "daysOfCover": expected a non-negative number.',
      );
    }

    final bool acknowledged;

    if (!json.containsKey('acknowledged')) {
      acknowledged = false;
    } else {
      final acknowledgedValue = json['acknowledged'];

      if (acknowledgedValue is! bool) {
        throw const FormatException(
          'Invalid "acknowledged": expected a boolean.',
        );
      }

      acknowledged = acknowledgedValue;
    }

    return StockAlert(
      id: id,
      medicineNameEn: medicineNameEn,
      medicineNameAr: medicineNameAr,
      severity: severity,
      daysOfCover: daysValue.toDouble(),
      branchCode: branchCode,
      acknowledged: acknowledged,
    );
  }

  StockAlert copyWith({
    String? id,
    String? medicineNameEn,
    String? medicineNameAr,
    Severity? severity,
    double? daysOfCover,
    String? branchCode,
    bool? acknowledged,
  }) {
    return StockAlert(
      id: id ?? this.id,
      medicineNameEn: medicineNameEn ?? this.medicineNameEn,
      medicineNameAr: medicineNameAr ?? this.medicineNameAr,
      severity: severity ?? this.severity,
      daysOfCover: daysOfCover ?? this.daysOfCover,
      branchCode: branchCode ?? this.branchCode,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StockAlert &&
        other.id == id &&
        other.medicineNameEn == medicineNameEn &&
        other.medicineNameAr == medicineNameAr &&
        other.severity == severity &&
        other.daysOfCover == daysOfCover &&
        other.branchCode == branchCode &&
        other.acknowledged == acknowledged;
  }

  @override
  int get hashCode => Object.hash(
        id,
        medicineNameEn,
        medicineNameAr,
        severity,
        daysOfCover,
        branchCode,
        acknowledged,
      );
}
