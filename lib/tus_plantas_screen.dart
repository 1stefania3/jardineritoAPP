import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medir_screen.dart';

class TusPlantasScreen extends StatelessWidget {
  const TusPlantasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tus Plantas"),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('MisPlantas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data!.docs;

          if (plants.isEmpty) {
            return const Center(
              child: Text(
                "No has añadido ninguna planta.",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index].data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 12,
                margin: const EdgeInsets.symmetric(vertical: 12),
                color: const Color.fromARGB(255, 255, 255, 255),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: plant['13_imagen'] != null
                            ? SizedBox(
                                width: double.infinity,
                                height: 180,
                                child: Image.network(
                                  plant['13_imagen'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported, size: 80),
                                ),
                              )
                            : const Icon(Icons.local_florist, size: 80, color: Colors.green),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        plant['01_Nombre'] ?? 'Sin nombre',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 108, 194, 112)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant['02_Descripción'] ?? 'Sin descripción.',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                  children: [
                    _infoRow(Icons.thermostat, 'Temperatura ideal:', plant['05_Temperatura']?['Ideal']),
                    _infoRow(Icons.light_mode, 'Luz:', plant['04_Luz']),
                    _infoRow(Icons.water_drop, 'Humedad recomendada:', plant['06_HumedadRecomendada']),
                    _infoRow(Icons.info_outline, 'Cuidados:', (plant['12_Cuidados'] as List?)?.join("\n• ") ?? 'No especificado'),
                    const SizedBox(height: 12),
                    _buttonRow(context, plants, index, plant),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buttonRow(BuildContext context, List<QueryDocumentSnapshot> plants, int index, Map<String, dynamic> plant) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedirPlantaScreen(planta: plant),
              ),
            );
          },
          icon: const Icon(Icons.sensors),
          label: const Text('Ir a medir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800, // Fondo más fuerte
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            elevation: 8,
            shadowColor: Colors.green.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            _confirmDelete(context, plants[index].id, plant['01_Nombre']);
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Eliminar planta'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            elevation: 8,
            shadowColor: Colors.red.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String docId, String? nombrePlanta) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar planta?'),
        content: Text('¿Estás seguro de que deseas eliminar "${nombrePlanta ?? 'esta planta'}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('MisPlantas').doc(docId).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${nombrePlanta ?? 'Planta'}" eliminada.')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar planta: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value?.toString() ?? 'No disponible', style: const TextStyle(fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
