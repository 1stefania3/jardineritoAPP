import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Historial")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('historial')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay registros aún."));
          }

          final datos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: datos.length,
            itemBuilder: (context, index) {
              final item = datos[index];

              // Usa try-catch para evitar que falle si faltan campos
              String nombre = 'Planta';
              String tipo = 'Medición';
              DateTime? fecha;

              try {
                nombre = item.get('planta') ?? 'Planta';
              } catch (_) {}

              try {
                tipo = item.get('tipo') ?? 'Medición';
              } catch (_) {}

              try {
                final fechaTimestamp = item.get('fecha');
                // Si 'fecha' es Timestamp de Firestore
                if (fechaTimestamp is Timestamp) {
                  fecha = fechaTimestamp.toDate();
                } else if (fechaTimestamp is String) {
                  fecha = DateTime.tryParse(fechaTimestamp);
                }
              } catch (_) {}

              final fechaFormateada =
                  fecha != null ? formatoFecha.format(fecha) : 'Fecha desconocida';

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text('$tipo - $nombre'),
                subtitle: Text(fechaFormateada),
              );
            },
          );
        },
      ),
    );
  }
}
