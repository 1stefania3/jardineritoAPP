import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedirScreen extends StatelessWidget {
  final Map<String, dynamic>? planta;

  const MedirScreen({super.key, this.planta});

  @override
  Widget build(BuildContext context) {
    final nombrePlanta = planta?['01_Nombre'] ?? 'Planta Desconocida';
    final imagenPlanta = planta?['13_imagen'] ?? 'assets/images/planta_default.png';

    return Scaffold(
      appBar: AppBar(
        title: Text('Mediciones de $nombrePlanta'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/arboles.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Aquí el título con fondo semitransparente para mejor legibilidad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Mediciones actuales',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _botonMedicion(
                  context,
                  icon: Icons.wb_sunny,
                  label: 'Luz',
                  color: Colors.amber.shade600,
                ),
                _botonMedicion(
                  context,
                  icon: Icons.thermostat,
                  label: 'Temperatura',
                  color: Colors.red.shade300,
                ),
                _botonMedicion(
                  context,
                  icon: Icons.water_drop,
                  label: 'Humedad',
                  color: Colors.blue.shade300,
                ),
                _botonMedicion(
                  context,
                  icon: Icons.opacity,
                  label: 'Riego',
                  color: Colors.teal.shade400,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(
                  image: imagenPlanta.startsWith('assets/')
                      ? AssetImage(imagenPlanta) as ImageProvider
                      : NetworkImage(imagenPlanta),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonMedicion(BuildContext context,
      {required IconData icon, required String label, required Color color}) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Función "$label" no implementada aún')),
        );
      },
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
