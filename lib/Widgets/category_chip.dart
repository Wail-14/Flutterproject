  import 'package:flutter/material.dart';
  import '../pages/category_places_page.dart';

  class CategoryChip extends StatelessWidget {
    final String label;
    final String city;
    final double lat;
    final double lon;

    const CategoryChip({
      super.key,
      required this.label,
      required this.city,
      required this.lat,
      required this.lon,
    });

    @override
    Widget build(BuildContext context) {
      return ChoiceChip(
        label: Text(label),
        selected: false,
        onSelected: (_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryPlacesPage(
                category: label,
                city: city,
                lat: lat,
                lon: lon,
              ),
            ),
          );
        },
      );
    }
  }
