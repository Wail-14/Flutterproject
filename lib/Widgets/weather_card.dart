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
        padding: const EdgeInsets.all(14), //  réduit pour compacter
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la ville
            Text(
              cityName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ), //  un peu plus petit
            ),

            const SizedBox(height: 8),

            //  Icône + Température + Min/Max sur UNE seule ligne
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  "https://openweathermap.org/img/wn/$icon@2x.png",
                  width: 55, //  bcp + compact
                  height: 55,
                ),

                const SizedBox(width: 12),

                // Température
                Text(
                  "${temperature.toInt()}°",
                  style: const TextStyle(
                    fontSize: 40, //  réduit
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                // Min / Max
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Min / Max"),
                    Text("${minTemp.toInt()}° / ${maxTemp.toInt()}°"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            //  Description - Humidité - Vent sur UNE ligne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("🌤 $description"),
                Text("💧 $humidity%"),
                Text("💨 $wind km/h"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
