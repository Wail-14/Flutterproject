import 'package:flutter/material.dart';
import '../models/Lieu.dart';
import '../db/lieux_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LieuDetailPage extends StatefulWidget {
  final Lieu lieu;

  const LieuDetailPage({super.key, required this.lieu});

  @override
  State<LieuDetailPage> createState() => _LieuDetailPageState();
}

class _LieuDetailPageState extends State<LieuDetailPage> {
  List<Map<String, Object?>> reviews = [];
  double avgRating = 0;
  double selectedRating = 3;
  final TextEditingController commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final r = await LieuxDatabase.getReviews(widget.lieu.id);
    final avg = await LieuxDatabase.getAverageRating(widget.lieu.id);

    setState(() {
      reviews = r;
      avgRating = avg;
    });
  }

  Future<void> _addReview() async {
    if (commentCtrl.text.trim().isEmpty) return;

    await LieuxDatabase.addReview(
      widget.lieu.id,
      selectedRating,
      commentCtrl.text.trim(),
    );

    commentCtrl.clear();
    selectedRating = 3;

    await _loadData(); // 🔥 Recharge commentaires + moyenne
  }
  // ----------------------------------------------------------
  //  Icônes premium (même design que dans HomePage)
  // ----------------------------------------------------------
  Widget premiumPin({
    required Color color,
    required IconData icon,
    double size = 44,
  }) {
    return Stack(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lieu.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE / ICONE SIMPLIFIÉE
            Hero(
              tag: "lieu-${widget.lieu.id}",
              child: getPremiumMarker(
                widget.lieu.category,
              ), // 🔥 Même icône que la map / favoris
            ),


            const SizedBox(height: 20),

            // TITRE
            Text(
              widget.lieu.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "Catégorie : ${widget.lieu.category}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            // NOTE MOYENNE
            Row(
              children: [
                const Text("Note moyenne :", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                _buildStars(avgRating),
                Text(" ${avgRating.toStringAsFixed(1)}"),
              ],
            ),

            const SizedBox(height: 20),

            // MAP
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(widget.lieu.lat, widget.lieu.lon),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.lieu.lat, widget.lieu.lon),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // COMMENTAIRES
            const Text(
              "Commentaires",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (reviews.isEmpty)
              const Text("Aucun commentaire pour le moment."),

            for (final r in reviews)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStars((r["rating"] as num).toDouble()),
                      const SizedBox(height: 5),
                      Text(r["comment"].toString()),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // AJOUTER UN COMMENTAIRE
            const Text(
              "Ajouter un commentaire",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // ÉTOILES
            Row(
              children: [
                const Text("Note :"),
                const SizedBox(width: 10),
                _ratingSelector(),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: commentCtrl,
              decoration: InputDecoration(
                hintText: "Votre commentaire...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              minLines: 1,
              maxLines: 3,
            ),

            const SizedBox(height: 10),

            ElevatedButton(onPressed: _addReview, child: const Text("Publier")),
          ],
        ),
      ),
    );
  }

  // ⭐⭐⭐⭐⭐ widget affichage fixe
  Widget _buildStars(double rating) {
    int full = rating.floor();
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < full ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 22,
        );
      }),
    );
  }

  // Sélecteur de note
  Widget _ratingSelector() {
    return Row(
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () {
            setState(() => selectedRating = i + 1.0);
          },
          child: Icon(
            i < selectedRating ? Icons.star : Icons.star_border,
            size: 28,
            color: Colors.orange,
          ),
        );
      }),
    );
  }
}
