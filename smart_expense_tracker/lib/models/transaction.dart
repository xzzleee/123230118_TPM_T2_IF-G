import 'dart:convert';

enum TransactionType { income, expense }

enum TransactionCategory {
  makan,
  transportasi,
  hiburan,
  belanja,
  kesehatan,
  pendidikan,
  gaji,
  lainnya,
}

extension TransactionCategoryExt on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.makan:
        return 'Makan';
      case TransactionCategory.transportasi:
        return 'Transportasi';
      case TransactionCategory.hiburan:
        return 'Hiburan';
      case TransactionCategory.belanja:
        return 'Belanja';
      case TransactionCategory.kesehatan:
        return 'Kesehatan';
      case TransactionCategory.pendidikan:
        return 'Pendidikan';
      case TransactionCategory.gaji:
        return 'Gaji';
      case TransactionCategory.lainnya:
        return 'Lainnya';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionCategory.makan:
        return '🍽️';
      case TransactionCategory.transportasi:
        return '🚌';
      case TransactionCategory.hiburan:
        return '🎮';
      case TransactionCategory.belanja:
        return '🛍️';
      case TransactionCategory.kesehatan:
        return '💊';
      case TransactionCategory.pendidikan:
        return '📚';
      case TransactionCategory.gaji:
        return '💼';
      case TransactionCategory.lainnya:
        return '📌';
    }
  }
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String note;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.index,
      'category': category.index,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values[map['type'] as int],
      category: TransactionCategory.values[map['category'] as int],
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}
