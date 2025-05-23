import 'package:flutter/material.dart';
import 'package:jardineritoapp/pantallas/explore_screen.dart';
import 'package:jardineritoapp/pantallas/inicio.dart';
import 'package:jardineritoapp/pantallas/mapa_islas_screen.dart'; 
import 'package:jardineritoapp/pantallas/home.dart'; 
import 'package:jardineritoapp/pantallas/ayuda_screen.dart';  // Importa la pantalla ayuda

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planti-Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PantallaInicio(),
        '/home': (context) => const PantallaHome(),
        '/explorar': (context) => ExploreScreen(),
        '/mapa': (context) => MapaIslasPersonalScreen(),
        '/ayuda': (context) => const AyudaScreen(),  // Ruta agregada
      },
    );
  }
}
