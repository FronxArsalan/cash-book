import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/transaction_service.dart';
import '../services/settings_service.dart';
import '../widgets/transaction_list.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionService = Provider.of<TransactionService>(context);
    final settingsService = Provider.of<SettingsService>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildBalanceCard(context, transactionService, settingsService, colorScheme),
          _buildSummaryCards(context, transactionService, settingsService, colorScheme),
          const Expanded(child: TransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const AddTransactionScreen()),
          );
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBalanceCard(BuildContext context, TransactionService transactionService, SettingsService settingsService, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(77), // 30% opacity
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '${settingsService.currencySymbol} ${transactionService.balance.toStringAsFixed(2)}',
            style: textTheme.displayMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, TransactionService transactionService, SettingsService settingsService, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SummaryCard(
              title: 'Income',
              amount: transactionService.totalIncome,
              currencySymbol: settingsService.currencySymbol,
              color: Colors.green.shade400,
              icon: Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              title: 'Expense',
              amount: transactionService.totalExpense,
              currencySymbol: settingsService.currencySymbol,
              color: Colors.red.shade400,
              icon: Icons.arrow_downward,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currencySymbol,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: textTheme.titleMedium),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol ${amount.toStringAsFixed(2)}',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
