import 'package:explorezvotreville/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'pages/accueil_page.dart';
import 'pages/home_page.dart';
import '/providers/weather_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart'; // pour kIsWeb
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web → IndexedDB
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Android/iOS/Linux/Mac/Windows
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AccueilPage(),
      routes: {'/home': (context) => const HomePage()},
    );
  }
}
