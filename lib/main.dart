import 'package:flutter/material.dart';
import 'package:jardineritoapp/pantallas/explore_screen.dart';
import 'package:jardineritoapp/pantallas/inicio.dart';
import 'package:jardineritoapp/pantallas/mapa_islas_screen.dart'; 
import 'package:jardineritoapp/pantallas/home.dart'; 

// pantalla de inicio después del botón
import 'package:firebase_core/firebase_core.dart';


// Asegúrate de importar ExplorarScreen correctamente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Asegura que Flutter esté listo para inicializar Firebase
  await Firebase.initializeApp();  // Inicializa Firebase
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
      initialRoute: '/',  // Definimos la ruta inicial
      routes: {
        '/': (context) =>  PantallaInicio(),
        '/home': (context) => const PantallaHome(),
        '/explorar': (context) => ExploreScreen (), 
        '/mapa': (context) => MapaIslasPersonalScreen(), // Pantalla del mapa
      },
    );
  }
}
