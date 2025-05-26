import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String budgetKey = 'budget_data';
  static const String expensesKey = 'expenses_data';
  static const String oneTimeExpensesKey = 'one_time_expenses_data';

  // Sauvegarder des données
  Future<void> saveData(String key, dynamic data) async {
    try {
      print('StorageService: Sauvegarde des données pour la clé $key');
      final String encodedData = json.encode(data);
      print('StorageService: Données encodées: $encodedData');

      if (kIsWeb) {
        // Utiliser localStorage pour le web
        html.window.localStorage[key] = encodedData;
      } else {
        // Utiliser SharedPreferences pour mobile
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, encodedData);
      }
      print('StorageService: Données sauvegardées avec succès');
    } catch (e) {
      print('StorageService: Erreur lors de la sauvegarde: $e');
      rethrow;
    }
  }

  // Charger des données
  Future<dynamic> loadData(String key) async {
    try {
      print('StorageService: Chargement des données pour la clé $key');
      String? data;

      if (kIsWeb) {
        // Utiliser localStorage pour le web
        data = html.window.localStorage[key];
      } else {
        // Utiliser SharedPreferences pour mobile
        final prefs = await SharedPreferences.getInstance();
        data = prefs.getString(key);
      }

      print('StorageService: Données brutes: $data');
      if (data != null) {
        final decodedData = json.decode(data);
        print('StorageService: Données décodées: $decodedData');
        return decodedData;
      }
      print('StorageService: Aucune donnée trouvée');
      return null;
    } catch (e) {
      print('StorageService: Erreur lors du chargement: $e');
      return null;
    }
  }

  // Supprimer des données
  Future<void> removeData(String key) async {
    try {
      print('StorageService: Suppression des données pour la clé $key');
      if (kIsWeb) {
        // Utiliser localStorage pour le web
        html.window.localStorage.remove(key);
      } else {
        // Utiliser SharedPreferences pour mobile
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      }
      print('StorageService: Données supprimées avec succès');
    } catch (e) {
      print('StorageService: Erreur lors de la suppression: $e');
      rethrow;
    }
  }

  // Vérifier si des données existent
  Future<bool> hasData(String key) async {
    try {
      print('StorageService: Vérification de l\'existence des données pour la clé $key');
      bool exists;

      if (kIsWeb) {
        // Utiliser localStorage pour le web
        exists = html.window.localStorage.containsKey(key);
      } else {
        // Utiliser SharedPreferences pour mobile
        final prefs = await SharedPreferences.getInstance();
        exists = prefs.containsKey(key);
      }

      print('StorageService: Données existent: $exists');
      return exists;
    } catch (e) {
      print('StorageService: Erreur lors de la vérification: $e');
      return false;
    }
  }
} 