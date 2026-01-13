class TradingRecord {
  final double profitOrLoss;
  final String reason;
  final double investment;
  final DateTime date;

  TradingRecord({
    required this.reason,
    required this.profitOrLoss,
    required this.investment,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'reson': reason,
    'profitOrLoss': profitOrLoss,
    'investment': investment,
    'date': date.toIso8601String(),
  };

  factory TradingRecord.fromMap(Map<String, dynamic> map) {
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return TradingRecord(
      reason: map['reson'],
      profitOrLoss: parseToDouble(map['profitOrLoss']),
      investment: parseToDouble(map['investment']),
      date: DateTime.parse(map['date'].toString()),
    );
  }
}
