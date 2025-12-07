import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import 'weather_card.dart';
import 'category_chip.dart';
import 'add_place_page.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/favorites_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  // ---------------- PREMIUM MAP PIN ----------------

  Widget premiumPin({
    required Color color,
    required IconData icon,
    double size = 44,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 250),
      scale: 1.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: size * 0.45,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withOpacity(0.95), color.withOpacity(0.7)],
                    ),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
                Icon(icon, color: Colors.white, size: size * 0.42),
              ],
            ),
          ),
          Positioned(
            bottom: -size * 0.12,
            child: Transform.rotate(
              angle: 3.14 / 4,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPremiumMarker(String category) {
    switch (category) {
      case "Musée":
        return premiumPin(color: const Color(0xFF8E44AD), icon: Icons.museum);
      case "Cinéma":
        return premiumPin(color: const Color(0xFF2980B9), icon: Icons.movie);
      case "Parc":
        return premiumPin(color: const Color(0xFF27AE60), icon: Icons.park);
      case "Théâtre":
        return premiumPin(
          color: const Color(0xFFE67E22),
          icon: Icons.theater_comedy,
        );
      case "Stade":
        return premiumPin(
          color: const Color(0xFFC0392B),
          icon: Icons.sports_soccer,
        );
      default:
        return premiumPin(color: Colors.black87, icon: Icons.location_on);
    }
  }

  // ---------------- STYLES DES CARDS FAVORIS ----------------

  Map<String, Map<String, dynamic>> cardStyles = {
    "Musée": {
      "colors": [Color(0xFF8E44AD), Color(0xFF9B59B6)],
      "icon": Icons.museum,
    },
    "Cinéma": {
      "colors": [Color(0xFF2980B9), Color(0xFF3498DB)],
      "icon": Icons.movie,
    },
    "Parc": {
      "colors": [Color(0xFF27AE60), Color(0xFF2ECC71)],
      "icon": Icons.park,
    },
    "Théâtre": {
      "colors": [Color(0xFFE67E22), Color(0xFFF39C12)],
      "icon": Icons.theater_comedy,
    },
    "Stade": {
      "colors": [Color(0xFFC0392B), Color(0xFFE74C3C)],
      "icon": Icons.sports_soccer,
    },

    // fallback
    "default": {
      "colors": [Colors.grey, Colors.black38],
      "icon": Icons.location_on,
    },
  };

  // ---------------- MAP UPDATE ----------------

  void updateMapIfNeeded(BuildContext context) {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    if (weather.hasData) {
      _mapController.move(LatLng(weather.selectedLat, weather.selectedLon), 13);
    }
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final weather = Provider.of<WeatherProvider>(context);
    final favorites = Provider.of<FavoritesProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateMapIfNeeded(context);
    });

    final currentCity = weather.cityName;

    favorites.loadFavorites(currentCity);
    final filteredFavorites = favorites.favorites;


    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorez Votre Ville"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- SEARCH ----------------
                TextField(
                  controller: _cityController,
                  onSubmitted: (text) async {
                    weather.clearSelectedCity();
                    setState(() {});
                    await weather.searchCity(text);

                    if (weather.cityResults.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Aucune ville trouvée.")),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Rechercher une ville...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Résultat",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // ---------------- CITY RESULTS ----------------
                if (weather.showCityList)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: weather.cityResults.length,
                      itemBuilder: (context, index) {
                        final city = weather.cityResults[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.location_city),
                            title: Text("${city['name']} (${city['country']})"),
                            subtitle: Text(
                              "lat: ${city['lat']} — lon: ${city['lon']}",
                            ),
                            onTap: () async {
                              await weather.chooseCity(city);
                              await Future.delayed(
                                const Duration(milliseconds: 120),
                              );
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),

                // ---------------- WEATHER CARD ----------------
                if (weather.hasData)
                  WeatherCard(
                    cityName: weather.cityName,
                    temperature: weather.temperature,
                    wind: weather.wind,
                    minTemp: weather.minTemp,
                    maxTemp: weather.maxTemp,
                    humidity: weather.humidity,
                    description: weather.description,
                    icon: weather.icon,
                  ),

                const SizedBox(height: 10),

                // ---------------- CATEGORIES ----------------
                if (weather.hasData)
                  Wrap(
                    spacing: 10,
                    children: [
                      CategoryChip(
                        label: "Musée",
                        city: currentCity,
                        lat: weather.selectedLat,
                        lon: weather.selectedLon,
                      ),
                      CategoryChip(
                        label: "Parc",
                        city: currentCity,
                        lat: weather.selectedLat,
                        lon: weather.selectedLon,
                      ),
                      CategoryChip(
                        label: "Cinéma",
                        city: currentCity,
                        lat: weather.selectedLat,
                        lon: weather.selectedLon,
                      ),
                      CategoryChip(
                        label: "Théâtre",
                        city: currentCity,
                        lat: weather.selectedLat,
                        lon: weather.selectedLon,
                      ),
                      CategoryChip(
                        label: "Stade",
                        city: currentCity,
                        lat: weather.selectedLat,
                        lon: weather.selectedLon,
                      ),
                      CategoryChip(
                        label: "Attraction",
                        city: currentCity,
                        lat: weather.selectedLat,
                        lon: weather.selectedLon,
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                // ---------------- MAP ----------------
                if (weather.hasData)
                  SizedBox(
                    height: 300,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          weather.selectedLat,
                          weather.selectedLon,
                        ),
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: favorites.favorites.map((place) {
                            return Marker(
                              width: 40,
                              height: 40,
                              point: LatLng(place.lat, place.lon),
                              child: getPremiumMarker(place.category),

                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                // ---------------- FAVORITES ----------------
                if (filteredFavorites.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Vos lieux favoris dans cette ville",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final fav = filteredFavorites[index];

                        final style = cardStyles[fav.category] ?? cardStyles["default"];

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(fav.name),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Catégorie : ${fav.category}"),
                                    Text("Latitude : ${fav.lat}"),
                                    Text("Longitude : ${fav.lon}"),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  style!["colors"][0],
                                  style["colors"][1],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  style["icon"],
                                  color: Colors.white,
                                  size: 50,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  fav.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Ajouter un lieu"),
              content: AddPlaceForm(
                onSubmit: (placeName) {
                  print("Lieu ajouté : $placeName");
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
