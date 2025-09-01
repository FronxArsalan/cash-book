import 'package:flutter/foundation.dart';
import 'dart:collection';

import '../models/transaction.dart';

class TransactionService with ChangeNotifier {
  final List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  UnmodifiableListView<Transaction> get transactions => UnmodifiableListView(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get balance => _transactions.fold(0.0, (sum, item) {
        return sum + (item.type == TransactionType.income ? item.amount : -item.amount);
      });

  double get totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  // Initialize with local storage (working version)
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));
      _setError(null);
    } catch (e) {
      _setError('Failed to initialize: $e');
      if (kDebugMode) {
        print('Error initializing transactions: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTransaction(String title, double amount, TransactionType type, DateTime date) async {
    try {
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        date: date,
        type: type,
      );

      _transactions.add(newTransaction);
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add transaction: $e');
      if (kDebugMode) {
        print('Error adding transaction: $e');
      }
    }
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      final txIndex = _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
      if (txIndex >= 0) {
        _transactions[txIndex] = updatedTransaction;
        _setError(null);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update transaction: $e');
      if (kDebugMode) {
        print('Error updating transaction: $e');
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      _transactions.removeWhere((tx) => tx.id == id);
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      if (kDebugMode) {
        print('Error deleting transaction: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
