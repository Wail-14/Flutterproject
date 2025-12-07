import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // prend toute la largeur
        height: double.infinity, // prend toute la hauteur
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation plus grande
            SizedBox(
              height: 380,
              child: Lottie.asset(
                'assets/lottie/Traveler.json',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // Titre principal
            const Text(
              "Explorez Votre Ville",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // PHRASE INSPIRANTE RAJOUTÉE
            const Text(
              "Découvrez les meilleurs lieux, restaurants, musées et parcs autour de vous.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 28,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Commencer", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
