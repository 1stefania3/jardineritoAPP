import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<String> historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      historial = prefs.getStringList('historial') ?? [];
    });
  }

  Future<void> _limpiarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historial');
    setState(() {
      historial.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text("Historial de Búsquedas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _limpiarHistorial,
            tooltip: 'Borrar historial',
          )
        ],
      ),
      body: Stack(
        children: [
          // Fondo con imagen
          Positioned.fill(
            child: Image.asset(
              'assets/images/arboles.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Fondo semitransparente
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Contenido del historial
          Padding(
            padding: const EdgeInsets.only(top: 80.0), // para que no tape el AppBar
            child: historial.isEmpty
                ? const Center(
                    child: Text(
                      "No hay historial aún.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: historial.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.eco, color: Colors.greenAccent),
                        title: Text(
                          historial[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
