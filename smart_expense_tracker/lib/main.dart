import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const SmartExpenseApp());
}

class SmartExpenseApp extends StatelessWidget {
  const SmartExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: MaterialApp(
        title: 'Smart Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00897B),
            primary: const Color(0xFF00897B),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          cardTheme: const CardThemeData(
            elevation: 1,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
