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

  // ======= Ville par défaut =======
  static const String defaultCity = "Orléans";
  static const double defaultLat = 47.902964;
  static const double defaultLon = 1.909251;

  double selectedLat = 0;
  double selectedLon = 0;

  List<Map<String, dynamic>> cityResults = [];
  bool hasData = false;
  bool showCityList = false;

  List<String> searchHistory = [];

  static const String apiKey = "f2abd7617c5007ee9ee812cfdc04970a";

  // 🔥 Flag pour éviter la sauvegarde au démarrage
  bool _isInit = true;

  // =======================================================
  //                CONSTRUCTEUR
  // =======================================================
  WeatherProvider() {
    _loadStoredCity(); // ⚠️ force Orléans
    _loadSearchHistory(); // charge l’historique
  }

  // =======================================================
  //        CHARGEMENT INITIAL : ORLÉANS UNIQUEMENT
  // =======================================================
  Future<void> _loadStoredCity() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 INITIALISATION UNE SEULE FOIS
    if (!prefs.containsKey("lastCity")) {
      await prefs.setString("lastCity", defaultCity);
    }

    // 🔥 DÉMARRAGE TOUJOURS SUR ORLÉANS
    final cities = await fetchCities(defaultCity);

    if (cities.isNotEmpty) {
      final data = await fetchWeatherByCoord(
        cities[0]["lat"],
        cities[0]["lon"],
      );
      updateInterface(data);
    }
  }


  // =======================================================
  //       SharedPreferences : Sauver ville (hors boot)
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
  //       SharedPreferences : Sauver recherche
  // =======================================================
  Future<void> _saveSearch(Map<String, dynamic> city) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonCity = jsonEncode(city);

    searchHistory.remove(jsonCity);
    searchHistory.insert(0, jsonCity);

    if (searchHistory.length > 5) {
      searchHistory = searchHistory.sublist(0, 5);
    }

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
        "https://api.openweathermap.org/data/2.5/weather"
        "?lat=$lat&lon=$lon&units=metric&lang=fr&appid=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Erreur API météo");
    }
    return json.decode(response.body);
  }

  // =======================================================
  //     Mise à jour UI
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

    // 🔥 On ne sauvegarde PAS la ville au démarrage
    if (!_isInit) {
      _saveCurrentCity(cityName);
    }

    _isInit = false;
    notifyListeners();
  }

  // =======================================================
  //     Recherche de ville
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

    if (cityResults.length == 1) {
      final city = cityResults[0];
      final weatherData = await fetchWeatherByCoord(city["lat"], city["lon"]);
      updateInterface(weatherData);
      await _saveSearch(city);
      return;
    }

    showCityList = true;
    hasData = false;
    notifyListeners();
  }

  // =======================================================
  //     Choix d’une ville
  // =======================================================
  Future<void> chooseCity(Map<String, dynamic> city) async {
    await _saveSearch(city);
    final data = await fetchWeatherByCoord(city["lat"], city["lon"]);
    updateInterface(data);
  }
}
