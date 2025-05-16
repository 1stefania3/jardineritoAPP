import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medir_screen.dart';


class TusPlantasScreen extends StatefulWidget {
  const TusPlantasScreen({super.key});

  @override
  State<TusPlantasScreen> createState() => _TusPlantasScreenState();
}

class _TusPlantasScreenState extends State<TusPlantasScreen> {
  Map<String, dynamic>? plantaSeleccionada;
  String? seccionActiva;

  // Listas de secciones para botones izquierda y derecha
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
    'Sustrato',
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
    final height = MediaQuery.of(context).size.height;

    final cubiculoWidth = (width - 48) / 3;

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/arboles.jpg',
                fit: BoxFit.cover,
              ),
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Mi Jardín',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('MisPlantas').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final plants = snapshot.data!.docs;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _cubiculoConTitulo(
                                width: cubiculoWidth,
                                label: 'Plantas',
                                value: plants.length.toString(),
                              ),
                              _cubiculoConTitulo(
                                width: cubiculoWidth,
                                label: 'Cubículo 2',
                                value: '2',
                              ),
                              _cubiculoConTitulo(
                                width: cubiculoWidth,
                                label: 'Cubículo 3',
                                value: '3',
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: plants.length,
                              itemBuilder: (context, index) {
                                final plantaData = plants[index].data() as Map<String, dynamic>;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      plantaSeleccionada = plantaData;
                                      seccionActiva = null;
                                    });
                                  },
                                  child: Container(
                                    width: width * 0.45,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: plantaSeleccionada == plantaData
                                          ? Colors.green.withOpacity(0.45)
                                          : Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.green.shade700, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade200.withOpacity(0.6),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
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
                                                      const Icon(Icons.image_not_supported, size: 70, color: Colors.green),
                                                )
                                              : const Icon(Icons.local_florist, size: 70, color: Colors.green),
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            plantaData['01_Nombre'] ?? 'Sin nombre',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(255, 108, 194, 112),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          if (plantaSeleccionada != null)
                            Container(
                              height: height * 0.6,
                              margin: const EdgeInsets.only(top: 30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
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
                                  // Botones izquierda
                                Expanded(
  flex: 2,
  child: ListView(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
    children: botonesIzquierda.map((titulo) {
      final isActive = seccionActiva == titulo;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.green.shade800 : Colors.green.shade400,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            elevation: isActive ? 6 : 2,
            shadowColor: isActive ? Colors.green.shade900 : Colors.black26,
          ),
          onPressed: () {
            setState(() {
              seccionActiva = titulo;
            });
          },
          child: Icon(iconosSecciones[titulo], size: 28, color: Colors.white),
        ),
      );
    }).toList(),
  ),
),


                                  // Contenido central
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: SingleChildScrollView(
                                        child: _contenidoSeccion(plantaSeleccionada!, seccionActiva),
                                      ),
                                    ),
                                  ),

                                  // Botones derecha
                              Expanded(
  flex: 2,
  child: ListView(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
    children: botonesDerecha.map((titulo) {
      final isActive = seccionActiva == titulo;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.green.shade800 : Colors.green.shade400,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            elevation: isActive ? 6 : 2,
            shadowColor: isActive ? Colors.green.shade900 : Colors.black26,
          ),
          onPressed: () {
            setState(() {
              seccionActiva = titulo;
            });
          },
          child: Icon(iconosSecciones[titulo], size: 28, color: Colors.white),
        ),
      );
    }).toList(),
  ),
),


                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
  padding: const EdgeInsets.all(16),
  child: SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedirScreen(planta: plantaSeleccionada),
          ),
        );
      },
      icon: const Icon(Icons.analytics),
      label: const Text('Ir a Medición'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
),

    );
  }

 Widget _contenidoSeccion(Map<String, dynamic> planta, String? seccionActiva) {
  if (seccionActiva == null) {
    return Center(
      child: Text(
        'Seleccione una sección para ver información',
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
          shadows: [
            Shadow(
              color: Colors.black12,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String contenido = '-';
  IconData icono = Icons.info_outline;

  switch (seccionActiva) {
    case 'Nombre':
      contenido = planta['01_Nombre'] ?? '-';
      icono = Icons.local_florist;
      break;

    case 'Descripción':
      contenido = planta['02_Descripción'] ?? '-';
      icono = Icons.description;
      break;

    case 'Ubicación Ideal':
      contenido = planta['03_UbicaciónIdeal'] ?? '-';
      icono = Icons.place;
      break;

    case 'Luz':
      contenido = planta['04_Luz'] ?? '-';
      icono = Icons.wb_sunny;
      break;

    case 'Temperatura':
      contenido = planta['05_Temperatura']?.toString() ?? '-';
      icono = Icons.thermostat;
      break;

    case 'Humedad Recomendada':
      contenido = planta['06_HumedadRecomendada'] ?? '-';
      icono = Icons.opacity;
      break;

    case 'Maceta':
      contenido = planta['07_Maceta'] ?? '-';
      icono = Icons.pets;
      break;

    case 'Riego':
      contenido = planta['08_Riego']?.toString() ?? '-';
      icono = Icons.grass;
      break;

    case 'Sustrato':
      contenido = planta['09_Sustrato'] ?? '-';
      icono = Icons.terrain;
      break;

    case 'Fertilización':
      contenido = planta['10_Fertilización'] ?? '-';
      icono = Icons.eco;
      break;

    case 'Problemas':
      contenido = planta['11_Problemas']?.toString() ?? '-';
      icono = Icons.report_problem;
      break;

    case 'Cuidados':
      contenido = planta['12_Cuidados']?.toString() ?? '-';
      icono = Icons.favorite;
      break;

    default:
      return const Text('Sección no disponible');
  }

  return Card(
    margin: const EdgeInsets.all(1),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Icon(icono, color: Colors.green[700], size: 28),
    const SizedBox(width: 10),
    Expanded( // <-- Esto evita el desbordamiento
      child: Text(
        seccionActiva,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
          shadows: [
            Shadow(
              color: Colors.black12,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    ),
  ],
),

          const SizedBox(height: 12),
          Text(
            contenido,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _cubiculoConTitulo({required double width, required String label, required String value}) {
    return Container(
      width: width,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
          ],
        ),
      ),
    );
  }
}
