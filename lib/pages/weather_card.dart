import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String cityName;
  final double temperature;
  final double wind;
  final double minTemp;
  final double maxTemp;
  final double humidity;
  final String description;
  final String icon;

  const WeatherCard({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.wind,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la ville
            Text(
              cityName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // Icône météo avec fond visible
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    "https://openweathermap.org/img/wn/$icon@4x.png",
                    width: 80,
                    height: 80,
                  ),
                ),

                const SizedBox(width: 16),

                Text(
                  "${temperature.toInt()}°",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Description"),
                    Text(description),
                    const SizedBox(height: 12),
                    const Text("Humidité"),
                    Text("$humidity%"),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Min / Max"),
                    Text("${minTemp.toInt()}° / ${maxTemp.toInt()}°"),
                    const SizedBox(height: 12),
                    const Text("Vent"),
                    Text("$wind km/h"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
