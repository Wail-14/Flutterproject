import 'package:explorezvotreville/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'pages/accueil_page.dart';
import 'pages/home_page.dart';
import '/providers/weather_provider.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'Explorez Votre Ville',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // Page de lancement
      home: const AccueilPage(),

      // Navigation simple
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}
