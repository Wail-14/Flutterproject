import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider with ChangeNotifier {
  // ======= Champs météo =======
  String cityName = "";
  double temperature = 0;
  double wind = 0;
  double minTemp = 0;
  double maxTemp = 0;
  double humidity = 0;
  String description = "";
  String icon = "";

  static const defaultCity = "Orléans";
  static const defaultLat = 47.902964;
  static const defaultLon = 1.909251;

  double selectedLat = 0;
  double selectedLon = 0;

  List<Map<String, dynamic>> cityResults = [];
  bool hasData = false;
  bool showCityList = false;

  List<String> searchHistory = [];

  static const String apiKey = "f2abd7617c5007ee9ee812cfdc04970a";

  // =======================================================
  //                CONSTRUCTEUR : initState()
  // =======================================================
  WeatherProvider() {
    _loadStoredCity();
    _loadSearchHistory();
  }

  // =======================================================
  //           SharedPreferences : Charger ville
  // =======================================================
  Future<void> _loadStoredCity() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCity = prefs.getString("lastCity") ?? defaultCity;

    // Récupérer coordonnées via l’API
    final cities = await fetchCities(savedCity);

    if (cities.isNotEmpty) {
      final data = await fetchWeatherByCoord(
        cities[0]["lat"],
        cities[0]["lon"],
      );
      updateInterface(data);
    }
  }

  // =======================================================
  //           SharedPreferences : Sauver ville
  // =======================================================
  Future<void> _saveCurrentCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("lastCity", city);
  }

  // =======================================================
  //    SharedPreferences : Charger l’historique (5 max)
  // =======================================================
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory = prefs.getStringList("history") ?? [];
    notifyListeners();
  }

  // =======================================================
  //       SharedPreferences : Sauver nouvelle recherche
  // =======================================================
 Future<void> _saveSearch(Map<String, dynamic> city) async {
    final prefs = await SharedPreferences.getInstance();

    // On convertit la ville en JSON
    final jsonCity = jsonEncode(city);

    // On évite les doublons exacts
    searchHistory.remove(jsonCity);

    // On ajoute en début de liste
    searchHistory.insert(0, jsonCity);

    // On limite à 5 villes
    if (searchHistory.length > 5) {
      searchHistory = searchHistory.sublist(0, 5);
    }

    // Sauvegarde
    await prefs.setStringList("history", searchHistory);
    notifyListeners();
  }


  // =======================================================
  //     API : Fetch villes
  // =======================================================
  Future<List<Map<String, dynamic>>> fetchCities(String city) async {
    final url =
        "https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=5&appid=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return [];

    final List data = json.decode(response.body);

    return data
        .map(
          (item) => {
            "name": item["name"],
            "lat": item["lat"],
            "lon": item["lon"],
            "country": item["country"],
          },
        )
        .toList();
  }

  // =======================================================
  //     API : Fetch météo
  // =======================================================
  Future<Map<String, dynamic>> fetchWeatherByCoord(
    double lat,
    double lon,
  ) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=fr&appid=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Erreur API météo");
    }
    return json.decode(response.body);
  }

  // =======================================================
  //     Update interface
  // =======================================================
  void updateInterface(Map<String, dynamic> data) {
    cityName = data["name"];
    temperature = data["main"]["temp"];
    minTemp = data["main"]["temp_min"];
    maxTemp = data["main"]["temp_max"];
    humidity = data["main"]["humidity"];
    wind = data["wind"]["speed"];
    description = data["weather"][0]["description"];
    icon = data["weather"][0]["icon"];

    selectedLat = data["coord"]["lat"];
    selectedLon = data["coord"]["lon"];

    hasData = true;
    showCityList = false;

    _saveCurrentCity(cityName); // 🔥 Sauvegarde automatique

    notifyListeners();
  }

  // =======================================================
  //     Méthode pour rechercher une ville
  // =======================================================
  Future<void> searchCity(String inputCity) async {
    if (inputCity.trim().isEmpty) return;

    cityResults = await fetchCities(inputCity);

    if (cityResults.isEmpty) {
      showCityList = false;
      hasData = false;
      notifyListeners();
      return;
    }

    // Si une seule ville → on charge, mais on NE sauvegarde pas encore l'historique ici
    if (cityResults.length == 1) {
      final city = cityResults[0];
      final weatherData = await fetchWeatherByCoord(city["lat"], city["lon"]);
      updateInterface(weatherData);

      // 🔥 SAUVEGARDE ICI car on a une vraie ville (et non juste du texte)
      await _saveSearch(city);

      return;
    }

    // Sinon → choix multiple
    showCityList = true;
    hasData = false;
    notifyListeners();
  }


  // =======================================================
  //     Choisir une ville dans la liste
  // =======================================================
  Future<void> chooseCity(Map<String, dynamic> city) async {
    await _saveSearch(city);
    final data = await fetchWeatherByCoord(city["lat"], city["lon"]);
    updateInterface(data);
  }
}
