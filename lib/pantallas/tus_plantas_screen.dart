import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medir_screen.dart';

class TusPlantasScreen extends StatefulWidget {
  const TusPlantasScreen({super.key});

  @override
  State<TusPlantasScreen> createState() => _TusPlantasScreenState();
}

class _TusPlantasScreenState extends State<TusPlantasScreen> {
  String? plantaSeleccionadaId; 
  Map<String, dynamic>? planta;
  String? seccionActiva;

  // Campos que mostrarás en los botones laterales, elimina o agrega según quieras
  final List<String> botonesIzquierda = [
    'Nombre',
    'Descripción',
    'Ubicación Ideal',
    'Luz',
    'Temperatura',
    'Humedad Recomendada',
  ];

  final List<String> botonesDerecha = [
    'Maceta',
    'Riego',
     'Sustrato', // omitido según pedido
    'Fertilización',
    'Problemas',
    'Cuidados',
  ];

  final Map<String, IconData> iconosSecciones = {
    'Nombre': Icons.label,
    'Descripción': Icons.description,
    'Ubicación Ideal': Icons.place,
    'Luz': Icons.wb_sunny,
    'Temperatura': Icons.thermostat,
    'Humedad Recomendada': Icons.water_drop,
    'Maceta': Icons.grass,
    'Riego': Icons.opacity,
    'Sustrato': Icons.filter_vintage,
    'Fertilización': Icons.eco,
    'Problemas': Icons.bug_report,
    'Cuidados': Icons.healing,
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/arboles.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('MisPlantas').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final plants = snapshot.data!.docs;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.green.shade700, width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.green.shade200.withOpacity(0.5),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Text(
    '🌿 MI JARDÍN TIENE ${plants.length} PLANTAS',
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.green.shade900,
      fontFamily: 'Arial',
    ),
    textAlign: TextAlign.center,
  ),
),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 210,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: plants.length,
                          itemBuilder: (context, index) {
                            final plantaData = plants[index].data() as Map<String, dynamic>;
                           final isSelected = plantaSeleccionadaId == plants[index].id;


                            return GestureDetector(
                             onTap: () {
  setState(() {
    plantaSeleccionadaId = plants[index].id; // guarda el ID
    planta = plants[index].data() as Map<String, dynamic>; // guarda el mapa completo aquí
    seccionActiva = null;
  });
},


                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isSelected ? width * 0.50 : width * 0.45,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.greenAccent.shade700
                                        : Colors.green.shade700,
                                    width: isSelected ? 3.5 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.shade200.withOpacity(0.6),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            topRight: Radius.circular(18),
                                          ),
                                          child: plantaData['13_imagen'] != null
                                              ? Image.network(
                                                  plantaData['13_imagen'],
                                                  height: 120,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.image_not_supported,
                                                          size: 70, color: Colors.green),
                                                )
                                              : const Icon(Icons.local_florist,
                                                  size: 70, color: Colors.green),
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            plantaData['01_Nombre']?.toString().replaceAll(RegExp(r'[{}]'), '') ?? 'Sin nombre',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade800,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                "Seleccionada",
                                                style: TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (plantaSeleccionadaId != null)
                        Container(
                          margin: const EdgeInsets.only(top: 30),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade700, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade200.withOpacity(0.6),
                                blurRadius: 14,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  children: botonesIzquierda.map((titulo) {
                                    final isActive = seccionActiva == titulo;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isActive
                                              ? Colors.green.shade800
                                              : Colors.green.shade400,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(16),
                                          elevation: isActive ? 6 : 2,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            seccionActiva = titulo;
                                          });
                                        },
                                        child: Icon(iconosSecciones[titulo],
                                            size: 28, color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _contenidoSeccion(plants.firstWhere((p) => p.id == plantaSeleccionadaId).data() as Map<String, dynamic>, seccionActiva),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  children: botonesDerecha.map((titulo) {
                                    final isActive = seccionActiva == titulo;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isActive
                                              ? Colors.green.shade800
                                              : Colors.green.shade400,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(16),
                                          elevation: isActive ? 6 : 2,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            seccionActiva = titulo;
                                          });
                                        },
                                        child: Icon(iconosSecciones[titulo],
                                            size: 28, color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              if (plantaSeleccionadaId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => MedirScreen(planta: planta),

                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecciona una planta primero')),
                );
              }
            },
            icon: const Icon(Icons.analytics),
            label: const Text('Ir a Medición'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenidoSeccion(Map<String, dynamic> planta, String? seccion) {
    if (seccion == null) {
      return const Text(
        'Selecciona una sección a la izquierda o derecha para ver detalles.',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }

    // Mapear nombres de sección a los nombres exactos de campos Firestore
    final Map<String, String> mapeoCampos = {
      'Nombre': '01_Nombre',
      'Descripción': '02_Descripción',
      'Ubicación Ideal': '03_Ubicación ideal',
      'Luz': '04_Luz',
      'Temperatura': '05_Temperatura',
      'Humedad Recomendada': '06_HumedadRecomendada',
      'Maceta': '07_Maceta',
      'Riego': '08_Riego',
      'Sustrato': '09_Sustrato',
      'Fertilización': '10_Fertilización',
      'Problemas': '11_Problemas',
      'Cuidados': '12_Cuidados',
    };

    final campo = mapeoCampos[seccion];

    final valor = campo != null && planta.containsKey(campo)
        ? planta[campo].toString().replaceAll(RegExp(r'[{}]'), '')
        : 'No disponible';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          seccion,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }
}
