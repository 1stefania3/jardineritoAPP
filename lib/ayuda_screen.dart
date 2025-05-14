import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayuda"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titulo de la pantalla
              Text(
                "¿Cómo puedo ayudarte?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 20),

              // Descripción general de la ayuda
              Text(
                "Aquí puedes encontrar información sobre cómo utilizar la aplicación, solucionar problemas comunes y obtener más detalles sobre cómo cuidar tus plantas.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Sección 1
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        "Cuidado de las plantas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Aquí te enseñamos cómo mantener a tus plantas saludables. Si tienes alguna duda sobre el riego, la luz o la temperatura, consulta esta sección.",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),

              // Sección 2
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        "Problemas comunes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "¿Tienes problemas con los sensores o no sabes cómo usar la app? ¡No te preocupes! En esta sección te ayudaremos a resolver cualquier inconveniente que puedas tener con los sensores y el funcionamiento de la aplicación.",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón para contactar ayuda
              ElevatedButton.icon(
                onPressed: () {
                  // Aquí se puede agregar la lógica para contactar ayuda
                },
                icon: const Icon(Icons.help_outline),
                label: const Text("Contactar soporte"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700, // Color de fondo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
