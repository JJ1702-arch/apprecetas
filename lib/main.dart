import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/screens/detalle_receta_screen.dart';
import 'package:recetasapp/screens/home_screen.dart';
import 'package:recetasapp/screens/splash_screen.dart';

void main() {
  runApp(const RecetasApp());
}

class RecetasApp extends StatelessWidget {
  const RecetasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas App by JJ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/detalle': (context) {
          final receta = ModalRoute.of(context)!.settings.arguments as Receta;
          return DetalleRecetaScreen(receta: receta);
        },
      },
    );
  }
}