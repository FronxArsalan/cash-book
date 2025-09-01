import 'package:flutter/foundation.dart';
import 'dart:collection';

import '../models/transaction.dart';

class TransactionService with ChangeNotifier {
  final List<Transaction> _transactions = [];

  UnmodifiableListView<Transaction> get transactions => UnmodifiableListView(_transactions);

  double get balance => _transactions.fold(0.0, (sum, item) {
        return sum + (item.type == TransactionType.income ? item.amount : -item.amount);
      });

  double get totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  void addTransaction(String title, double amount, TransactionType type, DateTime date) {
    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: date,
      type: type,
    );
    _transactions.add(newTransaction);
    notifyListeners();
  }

  void updateTransaction(Transaction updatedTransaction) {
    final txIndex = _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
    if (txIndex >= 0) {
      _transactions[txIndex] = updatedTransaction;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}
