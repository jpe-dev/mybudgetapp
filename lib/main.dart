import 'package:flutter/material.dart';
import 'models/recurring_expense.dart';
import 'models/expense.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final List<Expense> _expenses = [];
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  String _selectedCategory = expenseCategories[0];
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    print('Chargement des dépenses ponctuelles...');
    final data = await _storageService.loadData(StorageService.oneTimeExpensesKey);
    print('Données chargées: $data');
    if (data != null) {
      setState(() {
        _expenses.clear();
        _expenses.addAll(
          (data as List).map((item) => Expense.fromJson(item)).toList(),
        );
      });
      print('Nombre de dépenses chargées: ${_expenses.length}');
    } else {
      print('Aucune donnée trouvée');
    }
  }

  Future<void> _saveExpenses() async {
    print('Sauvegarde des dépenses ponctuelles...');
    final dataToSave = _expenses.map((e) => e.toJson()).toList();
    print('Données à sauvegarder: $dataToSave');
    await _storageService.saveData(
      StorageService.oneTimeExpensesKey,
      dataToSave,
    );
    print('Sauvegarde terminée');
  }

  void _startEditing(int index) {
    final expense = _expenses[index];
    setState(() {
      _editingIndex = index;
      _selectedCategory = expense.category;
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description;
      _selectedDate = expense.date;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _amountController.clear();
      _descriptionController.clear();
      _selectedDate = DateTime.now();
    });
  }

  void _deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la dépense'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette dépense ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _expenses.removeAt(index);
                _saveExpenses();
              });
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _addOrUpdateExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final expense = Expense(
          category: _selectedCategory,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text,
          date: _selectedDate,
        );

        if (_editingIndex != null) {
          _expenses[_editingIndex!] = expense;
          _editingIndex = null;
        } else {
          _expenses.add(expense);
        }

        _saveExpenses();
        // Réinitialiser le formulaire
        _amountController.clear();
        _descriptionController.clear();
        _selectedDate = DateTime.now();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépenses'),
      ),
      body: Column(
        children: [
          // Formulaire d'ajout/modification
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
                      labelText: 'Montant',
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
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_editingIndex != null)
                        ElevatedButton(
                          onPressed: _cancelEditing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Annuler'),
                        ),
                      ElevatedButton(
                        onPressed: _addOrUpdateExpense,
                        child: Text(_editingIndex != null ? 'Mettre à jour' : 'Ajouter la dépense'),
                      ),
                    ],
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(expense.category),
                    subtitle: Text(
                      '${expense.description}\n${expense.date.day}/${expense.date.month}/${expense.date.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CHF ${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _startEditing(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteExpense(index),
                        ),
                      ],
                    ),
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
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    print('Chargement des dépenses...');
    final data = await _storageService.loadData(StorageService.expensesKey);
    print('Données chargées: $data');
    if (data != null) {
      setState(() {
        _expenses.clear();
        _expenses.addAll(
          (data as List).map((item) => RecurringExpense.fromJson(item)).toList(),
        );
      });
      print('Nombre de dépenses chargées: ${_expenses.length}');
    } else {
      print('Aucune donnée trouvée');
    }
  }

  Future<void> _saveExpenses() async {
    print('Sauvegarde des dépenses...');
    final dataToSave = _expenses.map((e) => e.toJson()).toList();
    print('Données à sauvegarder: $dataToSave');
    await _storageService.saveData(
      StorageService.expensesKey,
      dataToSave,
    );
    print('Sauvegarde terminée');
  }

  void _startEditing(int index) {
    final expense = _expenses[index];
    setState(() {
      _editingIndex = index;
      _selectedCategory = expense.category;
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description;
      _selectedDay = expense.dayOfMonth;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _amountController.clear();
      _descriptionController.clear();
      _selectedDay = 1;
    });
  }

  void _deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la dépense récurrente'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette dépense récurrente ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _expenses.removeAt(index);
                _saveExpenses();
              });
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _addOrUpdateExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final expense = RecurringExpense(
          category: _selectedCategory,
          amount: double.parse(_amountController.text),
          dayOfMonth: _selectedDay,
          description: _descriptionController.text,
        );

        if (_editingIndex != null) {
          _expenses[_editingIndex!] = expense;
          _editingIndex = null;
        } else {
          _expenses.add(expense);
        }

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
          // Formulaire d'ajout/modification
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_editingIndex != null)
                        ElevatedButton(
                          onPressed: _cancelEditing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Annuler'),
                        ),
                      ElevatedButton(
                        onPressed: _addOrUpdateExpense,
                        child: Text(_editingIndex != null ? 'Mettre à jour' : 'Ajouter la dépense'),
                      ),
                    ],
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(expense.category),
                    subtitle: Text(expense.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CHF ${expense.amount.toStringAsFixed(2)}\nJour ${expense.dayOfMonth}',
                          textAlign: TextAlign.end,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _startEditing(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteExpense(index),
                        ),
                      ],
                    ),
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
