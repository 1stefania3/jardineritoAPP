import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedirScreen extends StatelessWidget {
  final Map<String, dynamic>? planta;

  const MedirScreen({Key? key, this.planta}) : super(key: key);

  void guardarMedicion(BuildContext context, String tipo) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    await firestore.collection('historial').add({
      'planta': planta?['01_Nombre'] ?? 'Planta desconocida',
      'tipo': tipo,
      'fecha': now.toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medición "$tipo" guardada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombrePlanta = planta?['01_Nombre'] ?? 'Planta sin nombre';

    return Scaffold(
      appBar: AppBar(title: Text('Medir - $nombrePlanta')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("¿Qué deseas medir?", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.thermostat),
              label: Text('Temperatura'),
              onPressed: () => guardarMedicion(context, 'Temperatura'),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.light_mode),
              label: Text('Luz'),
              onPressed: () => guardarMedicion(context, 'Luz'),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.water_drop),
              label: Text('Humedad'),
              onPressed: () => guardarMedicion(context, 'Humedad'),
            ),
          ],
        ),
      ),
    );
  }
}
