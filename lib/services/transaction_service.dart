import 'package:flutter/foundation.dart';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction.dart';
import 'firebase_service.dart';

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

  // Initialize and load transactions from Firestore
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Ensure user is authenticated
      if (FirebaseService.currentUserId == null) {
        await FirebaseService.signInAnonymously();
      }

      // Listen to transactions changes
      FirebaseService.transactionsCollection
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        _transactions.clear();
        for (var doc in snapshot.docs) {
          final transaction = Transaction.fromMap(doc.data() as Map<String, dynamic>);
          _transactions.add(transaction);
        }
        _setError(null);
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load transactions: $e');
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

      await FirebaseService.transactionsCollection.doc(newTransaction.id).set(newTransaction.toMap());
    } catch (e) {
      _setError('Failed to add transaction: $e');
      if (kDebugMode) {
        print('Error adding transaction: $e');
      }
    }
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      await FirebaseService.transactionsCollection
          .doc(updatedTransaction.id)
          .update(updatedTransaction.toMap());
    } catch (e) {
      _setError('Failed to update transaction: $e');
      if (kDebugMode) {
        print('Error updating transaction: $e');
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await FirebaseService.transactionsCollection.doc(id).delete();
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
