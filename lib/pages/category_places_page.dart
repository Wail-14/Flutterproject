import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'Lieu.dart';

class CategoryPlacesPage extends StatefulWidget {
  final String category;
  final String city;
  final double lat;
  final double lon;

  const CategoryPlacesPage({
    super.key,
    required this.category,
    required this.city,
    required this.lat,
    required this.lon,
  });

  @override
  State<CategoryPlacesPage> createState() => _CategoryPlacesPageState();
}

class _CategoryPlacesPageState extends State<CategoryPlacesPage> {
  List places = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) fetchPlaces();
    });
  }

  Future<void> fetchPlaces() async {
    String query;
    int radius = 5000;

    final servers = [
      "https://overpass.kumi.systems/api/interpreter",
      "https://overpass-api.de/api/interpreter",
    ];

    if (widget.category == "Parc") {
      radius = 10000;
      query =
          """
        [out:json][timeout:60];
        (
          nwr["leisure"="park"](around:$radius, ${widget.lat}, ${widget.lon});
          nwr["leisure"="garden"](around:$radius, ${widget.lat}, ${widget.lon});
          nwr["leisure"="nature_reserve"](around:$radius, ${widget.lat}, ${widget.lon});
        );
        out center;
      """;
    } else {
      final tags = {
        "Musée": '["tourism"="museum"]',
        "Cinéma": '["amenity"="cinema"]',
        "Théâtre": '["amenity"="theatre"]',
        "Stade": '["leisure"="stadium"]',
        "Attraction": '["tourism"="attraction"]',
      };

      final filter = tags[widget.category] ?? '["tourism"="attraction"]';

      query =
          """
        [out:json][timeout:60];
        (
          nwr$filter(around:$radius, ${widget.lat}, ${widget.lon});
        );
        out center;
      """;
    }

    for (final url in servers) {
      try {
        final response = await http
            .post(Uri.parse(url), body: {"data": query})
            .timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (!mounted) return;

          setState(() {
            places = data["elements"] ?? [];
            isLoading = false;
          });

          return;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.category} à ${widget.city}")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : places.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final item = places[index];
                final name = item["tags"]?["name"] ?? "Nom inconnu";

                final lat = item["lat"] ?? item["center"]?["lat"];
                final lon = item["lon"] ?? item["center"]?["lon"];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📍 $lat, $lon"),
                        if (item["tags"]?["addr:street"] != null)
                          Text("🏠 ${item["tags"]["addr:street"]}"),
                        if (item["tags"]?["addr:city"] != null)
                          Text("🏙️ ${item["tags"]["addr:city"]}"),
                      ],
                    ),
                    trailing: Consumer<FavoritesProvider>(
                      builder: (context, favs, _) {
                        final lieu = Lieu(
                          id: item["id"],
                          name: name,
                          category: widget.category,
                          lat: lat,
                          lon: lon,
                          city: widget.city,
                        );

                        final isFav = favs.isFavorite(lieu.id!);

                        print(
                          "🔍 [DEBUG] Lieu affiché : id=${lieu.id}, fav=$isFav",
                        );

                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                          ),
                          onPressed: () async {
                            print("❤️ [DEBUG] CLIC FAVORI sur ID ${lieu.id}");

                            await favs.toggleFavorite(lieu);

                            print(
                              "🔥 [DEBUG] Après toggle → isFavorite = ${favs.isFavorite(lieu.id!)}",
                            );
                            print(
                              "📦 [DEBUG] Contenu actuel favoris = ${favs.favorites.map((e) => e.id).toList()}",
                            );

                            setState(() {});
                          },
                        );
                      },
                    ),


                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Aucun lieu trouvé"));
  }
}
