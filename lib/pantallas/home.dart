import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];
  String currentWeather = "sun";
  String apiKey = "b63e04ebf20b511886ab20fd68bf34af";
  double temperature = 0.0;
  double humidity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    for (int i = 0; i < 30; i++) {
      _bubbles.add(Bubble.random());
    }
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      // Solicitar permisos
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('Permiso de ubicación denegado');
        return;
      }

      // Obtener posición actual
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherCondition = data['weather'][0]['main'].toString().toLowerCase();
        temperature = data['main']['temp'].toDouble();
        humidity = data['main']['humidity'].toDouble();

        setState(() {
          if (weatherCondition.contains('rain')) {
            currentWeather = 'rain';
          } else if (weatherCondition.contains('cloud')) {
            currentWeather = 'cloud';
          } else {
            currentWeather = 'sun';
          }
        });
      } else {
        print('Error al obtener el clima: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud o ubicación: $e');
    }
  }

  Widget _buildWeatherAnimation() {
    String asset;
    switch (currentWeather) {
      case 'rain':
        asset = 'assets/images/lottie/lluvia.json';
        break;
      case 'cloud':
        asset = 'assets/images/lottie/nubes.json';
        break;
      case 'sun':
      default:
        asset = 'assets/images/lottie/sol.json';
    }
    return Lottie.asset(
      asset,
      width: 140,
      height: 140,
      fit: BoxFit.contain,
      repeat: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente
        Container(
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/arboles.jpg'),
      fit: BoxFit.cover,
    ),
  ),
),
          // Burbujas tipo lámpara de lava
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                painter: BubblePainter(_bubbles, _controller.value),
                child: Container(),
              );
            },
          ),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  children: [
                    BounceInDown(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green[500],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _buildWeatherAnimation(), // Aquí se reemplaza el ícono por la animación Lottie
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInDown(
                      child: Text(
                        '¡Hola! Soy tu Jardinerito 🌱\n¿Qué quieres hacer hoy?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInDown(
                      child: Text(
                        'Temperatura: ${temperature.toStringAsFixed(1)}°C\nHumedad: ${humidity.toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: [
                        _buildBubbleButton(
                          context,
                          label: "Explorar",
                          imageAsset: "assets/images/explorar.png",
                          onTap: () => Navigator.pushNamed(context, '/mapa'),
                        ),
                        _buildBubbleButton(
                          context,
                          label: "Mis Plantas",
                          imageAsset: "assets/images/plantas.png",
                          onTap: () => Navigator.pushNamed(context, '/plantas'),
                        ),
                        _buildBubbleButton(
                          context,
                          label: "Historial",
                          imageAsset: "assets/images/historial.png",
                          onTap: () => Navigator.pushNamed(context, '/historial'),
                        ),
                        _buildBubbleButton(
                          context,
                          label: "Ayuda",
                          imageAsset: "assets/images/ayuda.png",
                          onTap: () => Navigator.pushNamed(context, '/ayuda'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleButton(
    BuildContext context, {
    required String label,
    required String imageAsset,
    required Function() onTap,
  }) {
    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imageAsset, width: 65, height: 65),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase burbuja para simular la lámpara de lava
class Bubble {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Bubble(this.x, this.y, this.size, this.speed, this.opacity);

  factory Bubble.random() {
    final random = Random();
    return Bubble(
      random.nextDouble(), // x
      random.nextDouble(), // y
      random.nextDouble() * 60 + 10, // tamaño
      random.nextDouble() * 0.3 + 0.05, // velocidad
      random.nextDouble() * 0.5 + 0.3, // opacidad
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;

  BubblePainter(this.bubbles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var bubble in bubbles) {
      final dx = bubble.x * size.width;
      final dy = (1.0 - ((bubble.y + bubble.speed * progress) % 1.0)) * size.height;

      paint.color = Colors.white.withOpacity(bubble.opacity);
      canvas.drawCircle(Offset(dx, dy), bubble.size * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
