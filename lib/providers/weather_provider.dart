import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // ======= Coordonnées de la ville sélectionnée =======
  double selectedLat = 0;
  double selectedLon = 0;

  // ======= Liste des villes proposées =======
  List<Map<String, dynamic>> cityResults = [];

  // ======= Pour l'UI =======
  bool hasData = false;
  bool showCityList = false;

  static const String apiKey = "f2abd7617c5007ee9ee812cfdc04970a";

  // --------------------------------------------------------------------
  // 1) FETCH pour chercher la liste des villes (comme AVANT dans HomePage)
  // --------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchCities(String city) async {
    final url =
        "https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=5&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final List data = json.decode(response.body);

    return data
        .map((item) => {
              "name": item["name"],
              "lat": item["lat"],
              "lon": item["lon"],
              "country": item["country"],
            })
        .toList();
  }

  // -----------------------------------------
  // 2) FETCH météo par coordonnées (comme AVANT)
  // -----------------------------------------
  Future<Map<String, dynamic>> fetchWeatherByCoord(
      double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=fr&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Erreur API météo");
    }

    return json.decode(response.body);
  }

  // -----------------------------------------
  // 3) Update Interface — EXACTEMENT COMME AVANT
  // -----------------------------------------
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

    notifyListeners();
  }

  // --------------------------------------------------------------------
  // 4) Méthode principale appelée depuis HomePage (recherche + comportement)
  // --------------------------------------------------------------------
  Future<void> searchCity(String inputCity) async {
    cityResults = await fetchCities(inputCity);

    // Aucun résultat
    if (cityResults.isEmpty) {
      showCityList = false;
      hasData = false;
      notifyListeners();
      return;
    }

    // SI UNE SEULE VILLE → charger immédiatement comme avant
    if (cityResults.length == 1) {
      final city = cityResults[0];

      final weatherData = await fetchWeatherByCoord(
        city["lat"],
        city["lon"],
      );

      updateInterface(weatherData);
      return;
    }

    // SINON → afficher la liste
    showCityList = true;
    hasData = false;
    notifyListeners();
  }

  // --------------------------------------------------------------------
  // 5) Appelé quand l’utilisateur clique sur une ville dans la liste
  // --------------------------------------------------------------------
  Future<void> chooseCity(Map<String, dynamic> city) async {
    final data = await fetchWeatherByCoord(
      city["lat"],
      city["lon"],
    );

    updateInterface(data);
  }

  void clearSelectedCity() {
    cityName = "";
    hasData = false;
    notifyListeners();
  }

}
