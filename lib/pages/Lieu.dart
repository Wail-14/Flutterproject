class Lieu {
  final int id; // <- id NON NULLABLE, important !
  final String name;
  final String category;
  final double lat;
  final double lon;
  final String city;

  Lieu({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lon,
    required this.city,
  });

  // Convertir en Map pour SQLite
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'lat': lat,
      'lon': lon,
      'city': city,
    };
  }

  // Reconstruire depuis SQLite
  factory Lieu.fromMap(Map<String, Object?> map) {
    return Lieu(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      lat: (map['lat'] as num).toDouble(), // ← sécurisé
      lon: (map['lon'] as num).toDouble(), // ← sécurisé
      city: map['city'] as String,
    );
  }
}
