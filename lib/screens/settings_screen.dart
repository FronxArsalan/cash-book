import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final textTheme = Theme.of(context).textTheme;

    final List<Map<String, String>> currencies = [
      {'name': 'Pakistani Rupee', 'symbol': 'Rs'},
      {'name': 'Indian Rupee', 'symbol': '₹'},
      {'name': 'US Dollar', 'symbol': '\$'},
      {'name': 'Euro', 'symbol': '€'},
      {'name': 'British Pound', 'symbol': '£'},
      {'name': 'Japanese Yen', 'symbol': '¥'},
      {'name': 'Russian Ruble', 'symbol': '₽'},
      {'name': 'UAE Dirham', 'symbol': 'د.إ'},
      {'name': 'Australian Dollar', 'symbol': 'A\$'},
      {'name': 'Canadian Dollar', 'symbol': 'C\$'},
      {'name': 'Swiss Franc', 'symbol': 'Fr'},
      {'name': 'Malaysian Ringgit', 'symbol': 'RM'},
    ];

    bool isCurrentSymbolInList = currencies.any((c) => c['symbol'] == settingsService.currencySymbol);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildCurrencySetting(context, settingsService, currencies, isCurrentSymbolInList),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Version 1.0.0'),
              onTap: () {
                // Show about dialog
                 showAboutDialog(
                  context: context,
                  applicationName: 'Cash Book',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Your Company',
                  children: <Widget>[
                    const SizedBox(height: 15),
                    const Text('A simple app to manage your daily income and expenses.')
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySetting(
    BuildContext context,
    SettingsService settingsService,
    List<Map<String, String>> currencies,
    bool isCurrentSymbolInList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Currency',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: isCurrentSymbolInList ? settingsService.currencySymbol : currencies.first['symbol'],
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          onChanged: (String? newSymbol) async {
            if (newSymbol != null) {
              try {
                await settingsService.setCurrency(newSymbol);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Currency updated successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${settingsService.error ?? e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          items: currencies.map<DropdownMenuItem<String>>((Map<String, String> currency) {
            return DropdownMenuItem<String>(
              value: currency['symbol'],
              child: Text('${currency['name']} (${currency['symbol']})'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
