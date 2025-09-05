import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/transaction_service.dart';
import '../services/settings_service.dart';
import '../models/transaction.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last 3 Months', 'This Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionService = Provider.of<TransactionService>(context);
    final settingsService = Provider.of<SettingsService>(context);
    final transactions = transactionService.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analysis'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Overview'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Categories'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Progress'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (BuildContext context) {
              return _periods.map((String period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(transactions, settingsService),
          _buildCategoriesTab(transactions, settingsService),
          _buildTrendsTab(transactions, settingsService),
          _buildProgressTab(transactions, settingsService),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(List<Transaction> transactions, SettingsService settingsService) {
    final filteredTransactions = _getFilteredTransactions(transactions);
    final analysis = _calculateAnalysis(filteredTransactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(analysis, settingsService),
          const SizedBox(height: 24),
          _buildBalanceChart(analysis, settingsService),
          const SizedBox(height: 24),
          _buildRecentTransactions(filteredTransactions, settingsService),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(List<Transaction> transactions, SettingsService settingsService) {
    final filteredTransactions = _getFilteredTransactions(transactions);
    final categoryData = _getCategoryAnalysis(filteredTransactions, settingsService);
    final paymentMethodData = _getPaymentMethodAnalysis(filteredTransactions, settingsService);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryPieChart(categoryData, settingsService),
          const SizedBox(height: 24),
          _buildPaymentMethodChart(paymentMethodData, settingsService),
          const SizedBox(height: 24),
          _buildCategoryList(categoryData, settingsService),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(List<Transaction> transactions, SettingsService settingsService) {
    final filteredTransactions = _getFilteredTransactions(transactions);
    final dailyData = _getDailyTrends(filteredTransactions, settingsService);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendChart(dailyData, settingsService),
          const SizedBox(height: 24),
          _buildTrendInsights(dailyData, settingsService),
        ],
      ),
    );
  }

  Widget _buildProgressTab(List<Transaction> transactions, SettingsService settingsService) {
    final filteredTransactions = _getFilteredTransactions(transactions);
    final analysis = _calculateAnalysis(filteredTransactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressOverview(analysis, settingsService),
          const SizedBox(height: 24),
          _buildFinancialGoals(analysis, settingsService),
          const SizedBox(height: 24),
          _buildProgressMetrics(analysis, settingsService),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AnalysisData analysis, SettingsService settingsService) {
    return Column(
      children: [
        // First row - Income and Expense
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Income',
                amount: analysis.totalIncome,
                currencySymbol: settingsService.currencySymbol,
                color: Colors.green,
                icon: Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                title: 'Total Expense',
                amount: analysis.totalExpense,
                currencySymbol: settingsService.currencySymbol,
                color: Colors.red,
                icon: Icons.arrow_downward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - Balance and Transactions
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Net Balance',
                amount: analysis.netBalance,
                currencySymbol: settingsService.currencySymbol,
                color: analysis.netBalance >= 0 ? Colors.blue : Colors.orange,
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                title: 'Transactions',
                amount: analysis.transactionCount.toDouble(),
                currencySymbol: '',
                color: Colors.purple,
                icon: Icons.receipt_long,
                isCount: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceChart(AnalysisData analysis, SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expense',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: analysis.totalIncome,
                      title: 'Income\n${settingsService.currencySymbol} ${analysis.totalIncome.toStringAsFixed(0)}',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: analysis.totalExpense,
                      title: 'Expense\n${settingsService.currencySymbol} ${analysis.totalExpense.toStringAsFixed(0)}',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> categoryData, SettingsService settingsService) {
    if (categoryData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No expense data available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((entry) {
                    final index = categoryData.keys.toList().indexOf(entry.key);
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.key}\n${settingsService.currencySymbol} ${entry.value.toStringAsFixed(0)}',
                      color: colors[index % colors.length],
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChart(Map<String, double> paymentData, SettingsService settingsService) {
    if (paymentData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = paymentData.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < paymentData.keys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                paymentData.keys.elementAt(index),
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${settingsService.currencySymbol} ${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: paymentData.entries.map((entry) {
                    final index = paymentData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<DailyData> dailyData, SettingsService settingsService) {
    if (dailyData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No trend data available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final maxIncome = dailyData.map((d) => d.income).reduce((a, b) => a > b ? a : b);
    final maxExpense = dailyData.map((d) => d.expense).reduce((a, b) => a > b ? a : b);
    final maxValue = maxIncome > maxExpense ? maxIncome : maxExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dailyData.length) {
                            return Text(
                              DateFormat('MMM dd').format(dailyData[index].date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${settingsService.currencySymbol} ${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.income);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: dailyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.expense);
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegendItem('Income', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('Expense', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions, SettingsService settingsService) {
    final recentTransactions = transactions.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recentTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No recent transactions'),
                ),
              )
            else
              ...recentTransactions.map((transaction) {
                final isIncome = transaction.type == TransactionType.income;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
                    child: Icon(
                      isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}${settingsService.currencySymbol} ${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> categoryData, SettingsService settingsService) {
    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final percentage = (entry.value / categoryData.values.reduce((a, b) => a + b)) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${settingsService.currencySymbol} ${entry.value.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendInsights(List<DailyData> dailyData, SettingsService settingsService) {
    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalIncome = dailyData.fold(0.0, (sum, data) => sum + data.income);
    final totalExpense = dailyData.fold(0.0, (sum, data) => sum + data.expense);
    final avgDailyIncome = totalIncome / dailyData.length;
    final avgDailyExpense = totalExpense / dailyData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Average Daily Income',
              '${settingsService.currencySymbol} ${avgDailyIncome.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.green,
            ),
            _buildInsightItem(
              'Average Daily Expense',
              '${settingsService.currencySymbol} ${avgDailyExpense.toStringAsFixed(2)}',
              Icons.trending_down,
              Colors.red,
            ),
            _buildInsightItem(
              'Savings Rate',
              '${((totalIncome - totalExpense) / totalIncome * 100).toStringAsFixed(1)}%',
              Icons.savings,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(AnalysisData analysis, SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Savings Rate',
                    '${analysis.totalIncome > 0 ? ((analysis.netBalance / analysis.totalIncome) * 100).toStringAsFixed(1) : '0.0'}%',
                    Colors.green,
                    Icons.savings,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressItem(
                    'Expense Ratio',
                    '${analysis.totalIncome > 0 ? ((analysis.totalExpense / analysis.totalIncome) * 100).toStringAsFixed(1) : '0.0'}%',
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialGoals(AnalysisData analysis, SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Goals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGoalItem(
              'Monthly Income Target',
              '${settingsService.currencySymbol} 50,000',
              analysis.totalIncome,
              50000,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Monthly Expense Limit',
              '${settingsService.currencySymbol} 30,000',
              analysis.totalExpense,
              30000,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              'Savings Target',
              '${settingsService.currencySymbol} 20,000',
              analysis.netBalance,
              20000,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetrics(AnalysisData analysis, SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricItem(
              'Financial Health Score',
              _calculateHealthScore(analysis),
              Colors.blue,
              Icons.health_and_safety,
            ),
            _buildMetricItem(
              'Spending Efficiency',
              _calculateSpendingEfficiency(analysis),
              Colors.orange,
              Icons.speed,
            ),
            _buildMetricItem(
              'Transaction Activity',
              analysis.transactionCount > 10 ? 85.0 : (analysis.transactionCount * 8.5),
              Colors.green,
              Icons.receipt_long,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalItem(String title, String target, double current, double goal, Color color) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${current.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
            Text(
              target,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String title, double value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateHealthScore(AnalysisData analysis) {
    if (analysis.totalIncome == 0) return 0.0;
    final savingsRate = (analysis.netBalance / analysis.totalIncome) * 100;
    return savingsRate.clamp(0.0, 100.0);
  }

  double _calculateSpendingEfficiency(AnalysisData analysis) {
    if (analysis.totalIncome == 0) return 0.0;
    final efficiency = (analysis.totalIncome / (analysis.totalIncome + analysis.totalExpense)) * 100;
    return efficiency.clamp(0.0, 100.0);
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return transactions.where((transaction) {
      return transaction.date.isAfter(startDate) || transaction.date.isAtSameMomentAs(startDate);
    }).toList();
  }

  AnalysisData _calculateAnalysis(List<Transaction> transactions) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return AnalysisData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: totalIncome - totalExpense,
      transactionCount: transactions.length,
    );
  }

  Map<String, double> _getCategoryAnalysis(List<Transaction> transactions, SettingsService settingsService) {
    final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense);
    final categoryMap = <String, double>{};

    for (final transaction in expenseTransactions) {
      // For now, we'll use payment method as category
      // In a real app, you might have a separate category field
      final category = _getPaymentMethodLabel(transaction.paymentMethod);
      categoryMap[category] = (categoryMap[category] ?? 0) + transaction.amount;
    }

    return categoryMap;
  }

  Map<String, double> _getPaymentMethodAnalysis(List<Transaction> transactions, SettingsService settingsService) {
    final paymentMap = <String, double>{};

    for (final transaction in transactions) {
      final method = _getPaymentMethodLabel(transaction.paymentMethod);
      paymentMap[method] = (paymentMap[method] ?? 0) + transaction.amount;
    }

    return paymentMap;
  }

  List<DailyData> _getDailyTrends(List<Transaction> transactions, SettingsService settingsService) {
    final Map<DateTime, DailyData> dailyMap = {};

    for (final transaction in transactions) {
      final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      if (!dailyMap.containsKey(date)) {
        dailyMap[date] = DailyData(date: date, income: 0, expense: 0);
      }

      if (transaction.type == TransactionType.income) {
        dailyMap[date]!.income += transaction.amount;
      } else {
        dailyMap[date]!.expense += transaction.amount;
      }
    }

    final dailyList = dailyMap.values.toList();
    dailyList.sort((a, b) => a.date.compareTo(b.date));
    return dailyList;
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.online:
        return 'Online';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final Color color;
  final IconData icon;
  final bool isCount;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currencySymbol,
    required this.color,
    required this.icon,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isCount 
                ? amount.toInt().toString()
                : '$currencySymbol ${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisData {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int transactionCount;

  AnalysisData({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.transactionCount,
  });
}

class DailyData {
  final DateTime date;
  double income;
  double expense;

  DailyData({
    required this.date,
    required this.income,
    required this.expense,
  });
}