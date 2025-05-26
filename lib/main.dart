import 'package:flutter/material.dart';
import 'models/recurring_expense.dart';
import 'services/storage_service.dart';

// Liste des catégories prédéfinies
final List<String> expenseCategories = [
  'Loyer',
  'Électricité',
  'Eau',
  'Internet/Téléphone',
  'Courses',
  'Transport',
  'Loisirs',
  'Santé',
  'Assurances',
  'Autres'
];

void main() {
  runApp(const MyBudgetApp());
}

class MyBudgetApp extends StatelessWidget {
  const MyBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Budget App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ExpensesPage(),
    const BudgetPage(),
    const StatisticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Dépenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiques',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard - Vue d\'ensemble'),
    );
  }
}

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Page des dépenses'),
    );
  }
}

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final List<RecurringExpense> _expenses = [];
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  String _selectedCategory = expenseCategories[0];
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await _storageService.loadData(StorageService.expensesKey);
    if (data != null) {
      setState(() {
        _expenses.clear();
        _expenses.addAll(
          (data as List).map((item) => RecurringExpense.fromJson(item)).toList(),
        );
      });
    }
  }

  Future<void> _saveExpenses() async {
    await _storageService.saveData(
      StorageService.expensesKey,
      _expenses.map((e) => e.toJson()).toList(),
    );
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _expenses.add(
          RecurringExpense(
            category: _selectedCategory,
            amount: double.parse(_amountController.text),
            dayOfMonth: _selectedDay,
            description: _descriptionController.text,
          ),
        );
        _saveExpenses();
        // Réinitialiser le formulaire
        _amountController.clear();
        _descriptionController.clear();
        _selectedDay = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration du Budget'),
      ),
      body: Column(
        children: [
          // Formulaire d'ajout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: expenseCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Montant mensuel',
                      border: OutlineInputBorder(),
                      prefixText: 'CHF ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Jour du mois : '),
                      Expanded(
                        child: Slider(
                          value: _selectedDay.toDouble(),
                          min: 1,
                          max: 31,
                          divisions: 30,
                          label: _selectedDay.toString(),
                          onChanged: (double value) {
                            setState(() {
                              _selectedDay = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text('$_selectedDay'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addExpense,
                    child: const Text('Ajouter la dépense'),
                  ),
                ],
              ),
            ),
          ),
          // Liste des dépenses
          Expanded(
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return ListTile(
                  title: Text(expense.category),
                  subtitle: Text(expense.description),
                  trailing: Text(
                    'CHF ${expense.amount.toStringAsFixed(2)}\nJour ${expense.dayOfMonth}',
                    textAlign: TextAlign.end,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Statistiques et analyses'),
    );
  }
}
