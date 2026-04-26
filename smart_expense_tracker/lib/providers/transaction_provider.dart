import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  static const String _storageKey = 'transactions_data';

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  TransactionProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> data = prefs.getStringList(_storageKey) ?? [];
      _transactions = data.map((e) => Transaction.fromJson(e)).toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> data = _transactions.map((t) => t.toJson()).toList();
      await prefs.setStringList(_storageKey, data);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.insert(0, transaction);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveToStorage();
    notifyListeners();
  }
}
