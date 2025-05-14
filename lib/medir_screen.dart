import 'package:flutter/material.dart';
import 'package:jardineritoapp/next_screen.dart';
import 'dart:math';
import 'pantallas/explore_screen.dart';
import 'tus_plantas_screen.dart';
import 'historial_screen.dart';
import 'ayuda_screen.dart';
import 'riego.dart';  // Asegúrate de importar la pantalla de Riego
class MedirPlantaScreen extends StatefulWidget {
  final Map<String, dynamic> planta;

  const MedirPlantaScreen({super.key, required this.planta});

  @override
  _MedirPlantaScreenState createState() => _MedirPlantaScreenState();
}

class _MedirPlantaScreenState extends State<MedirPlantaScreen> {
  int _currentIndex = 0;  // Aquí inicializamos el índice actual

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F7E9),
      appBar: AppBar(
        title: Text("Medir: ${widget.planta['01_Nombre'] ?? 'Planta'}"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          _patronDecorativoDeFondo(),
          Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/jardinenmaceta.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  _florPetalo(context, 0, Icons.lightbulb_outline, "Luz", "💡 Luz actual: 15000 lx", Colors.amber),
                  _florPetalo(context, 72, Icons.water_drop, "Humedad", "💧 Humedad actual: 70%", Colors.blue),
                  _florPetalo(context, 144, Icons.thermostat, "Temperatura", "🌡️ Temperatura actual: 25°C", Colors.red),
                  _florPetalo(context, 216, Icons.science, "pH", "🧪 pH actual: 6.5", Colors.purple),
                  Positioned(
                    top: 20,
                    left: MediaQuery.of(context).size.width / 2 ,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RiegoScreen(planta: widget.planta)), 
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.water_drop, color: Colors.green.shade800, size: 40),
                                const SizedBox(height: 4),
                                Text(
                                  "Riego",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,  // Usamos el índice mutable
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // Actualizamos el índice al seleccionar un elemento
          });

          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NextScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExploreScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TusPlantasScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistorialScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AyudaScreen()),
              );
              break;
            default:
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Mis Plantas'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Ayuda'),
        ],
      ),
    );
  }

  Widget _florPetalo(BuildContext context, double angleDegrees, IconData icon, String label, String mensaje, MaterialColor color) {
    final double radius = 140;
    final double angleRadians = angleDegrees * pi / 180;

    final double dx = radius * cos(angleRadians);
    final double dy = radius * sin(angleRadians);

    return Positioned(
      left: 200 + dx - 50,
      top: 200 + dy - 50,
      child: InkWell(
        onTap: () => _mostrarResultado(context, mensaje),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color.shade800, size: 40),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarResultado(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resultado de medición'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _patronDecorativoDeFondo() {
    final iconos = [
      Icons.emoji_nature,
      Icons.wb_sunny,
      Icons.thermostat,
      Icons.water_drop,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final alto = constraints.maxHeight;
        final tam = 60.0;

        List<Widget> elementos = [];
        for (double y = 0; y < alto; y += tam) {
          for (double x = 0; x < ancho; x += tam) {
            final icon = iconos[((x + y).toInt() ~/ tam) % iconos.length];
            elementos.add(Positioned(
              left: x,
              top: y,
              child: Icon(
                icon,
                color: Colors.green.shade800.withOpacity(0.15),
                size: 30,
              ),
            ));
          }
        }

        return Stack(children: elementos);
      },
    );
  }
}