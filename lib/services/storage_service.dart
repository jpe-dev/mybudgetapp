import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String budgetKey = 'budget_data';
  static const String expensesKey = 'expenses_data';

  // Sauvegarder des données
  Future<void> saveData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(data);
    await prefs.setString(key, encodedData);
  }

  // Charger des données
  Future<dynamic> loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(key);
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  // Supprimer des données
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Vérifier si des données existent
  Future<bool> hasData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
} 