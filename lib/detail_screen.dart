import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, String> plant;

  const DetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          plant["name"] ?? "Planta Desconocida",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlantImage(),
              const SizedBox(height: 16),
              Text("CARACTERÍSTICAS", style: _titleStyle),
              const SizedBox(height: 8),
              _buildDetailRow("Nombre Científico", plant["scientific_name"]),
              _buildDetailRow("Origen", plant["origin"]),
              _buildDetailRow("Descripción", plant["description"]),
              const SizedBox(height: 16),
              Text("CUIDADOS GENERALES", style: _titleStyle),
              const SizedBox(height: 8),
              Text(
                _getCareInstructions(plant["name"]),
                style: _bodyStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼️ Carga segura de imágenes con placeholder y error handling
Widget _buildPlantImage() {
  if (plant["image"] == null || plant["image"]!.isEmpty) {
    return const SizedBox.shrink(); // No muestra nada si la imagen no existe
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.asset(
      plant["image"]!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 250,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
      },
    ),
  );
}


  /// 📌 Construcción de filas con validación de datos
  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: _bodyStyle,
          children: [
            TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value ?? "No disponible"),
          ],
        ),
      ),
    );
  }

  /// 🌿 Información sobre los cuidados de la planta
  String _getCareInstructions(String? plantName) {
    switch (plantName) {
      case "Prímula":
        return "Lugar fresco, luminoso y con humedad. Suelo bien drenado para evitar encharcamientos.";
      case "Mandarino":
        return "Exposición solar abundante y riego semanal.";
      case "Orquídea":
        return "Ambiente cálido y húmedo, riego moderado y evitar la luz solar directa.";
      default:
        return "No hay información disponible.";
    }
  }

  /// 🎨 Estilos para mayor consistencia
  static const TextStyle _titleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const TextStyle _bodyStyle = TextStyle(fontSize: 16, color: Colors.black);
}
