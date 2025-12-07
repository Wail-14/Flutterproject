import 'package:flutter/material.dart';
import '../pages/lieux_database.dart';
import '../pages/Lieu.dart';

class FavoritesProvider with ChangeNotifier {
  List<Lieu> favorites = [];

  Future<void> loadFavorites(String city) async {
    favorites = await LieuxDatabase.lieuxForCity(city);
    notifyListeners();
  }

  Future<void> addFavorite(Lieu lieu) async {
    await LieuxDatabase.insertLieu(lieu);
    favorites.add(lieu);
    notifyListeners();
  }

  Future<void> removeFavorite(int id) async {
    await LieuxDatabase.deleteLieu(id);
    favorites.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(Lieu lieu) async {
    final exists = favorites.any((p) => p.id == lieu.id);

    if (exists) {
      await removeFavorite(lieu.id);
    } else {
      await addFavorite(lieu);
    }
  }

  // 🔥 Méthode supplémentaire indispensable
  bool isFavorite(int id) {
    return favorites.any((l) => l.id == id);
  }
}
