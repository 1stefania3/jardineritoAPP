import 'package:flutter/material.dart';
import 'dart:async';

// Importa la pantalla a la que quieres navegar
import 'explore_screen.dart'; 
import 'medicinales.dart';
import 'arboles.dart';
import 'ornamentales.dart';
import 'tus_plantas_screen.dart';
import 'home.dart';// Ajusta la ruta según dónde tengas tu ExploreScreen

class MapaIslasPersonalScreen extends StatefulWidget {
  const MapaIslasPersonalScreen({super.key});

  @override
  State<MapaIslasPersonalScreen> createState() => _MapaIslasPersonalScreenState();
}

class _MapaIslasPersonalScreenState extends State<MapaIslasPersonalScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationFloat;
  late Timer _cicloTimer;
  int _islaDestino = 0;
  Offset _posicionActual = Offset.zero;
  Offset _posicionObjetivo = Offset.zero;

  final List<Offset> _posicionesIslas = [];
  final List<String> _mensajesCuriosos = [
    '¿Sabías que algunas plantas ornamentales purifican el aire?',
    'Las plantas medicinales han sido usadas por siglos.',
    'Los árboles ayudan a regular el clima.',
    '¡Aquí puedes ver todas las plantas disponibles!',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Más lento
    )..repeat(reverse: true);

    _animationFloat = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      _posicionesIslas.add(const Offset(30, 60)); // Ornamental
      _posicionesIslas.add(Offset(size.width - 160, size.height - 280)); // Medicinal
      _posicionesIslas.add(const Offset(30, 270)); // Árboles
      _posicionesIslas.add(Offset(size.width - 180, 60)); // Todas

      _posicionActual = _posicionesIslas[0];
      _posicionObjetivo = _posicionesIslas[0];

      _cicloTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        final siguiente = (_islaDestino + 1) % _posicionesIslas.length;

        setState(() {
          _posicionActual = _posicionObjetivo;
          _posicionObjetivo = _posicionesIslas[siguiente];
          _islaDestino = siguiente;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _cicloTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Offset pos = (_posicionesIslas.length == 4)
        ? _posicionesIslas[_islaDestino]
        : Offset(MediaQuery.of(context).size.width / 2 - 60, 100);

    return Scaffold(
      
      body: Stack(
        children: [
       
          // Fondo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(151, 67, 110, 27), Color.fromARGB(127, 124, 91, 1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Burbujas decorativas
          ..._buildBurbujas(),

          // Canvas para curvas
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConexionPainter(),
          ),

          // Islas (antes para que estén detrás)
          Positioned(
            bottom: 60,
            left: 30,
            child: IslaImagenCustom(
              imagePath: 'assets/images/orna.png',
              numero: '1',
              nombre: 'Ornamentales',
              onTap: () {
                // Navegar a la pantalla ExploreScreen al hacer click en "Todas"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrnamentalesScreen()),
                );
              },
            ),
          ),
          Positioned(
            bottom: 220,
            right: 30,
            child: IslaImagenCustom(
              imagePath: 'assets/images/medi.png',
              numero: '2',
              nombre: 'Medicinales',
               onTap: () {
                // Navegar a la pantalla ExploreScreen al hacer click en "Todas"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicinalesScreen()),
                );
              },
            ),
          ),
          Positioned(
            top: 270,
            left: 30,
            child: IslaImagenCustom(
              imagePath: 'assets/images/arb.png',
              numero: '3',
              nombre: 'Árboles',
              onTap: () {
                // Navegar a la pantalla ExploreScreen al hacer click en "Todas"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArbolesScreen()),
                );
              },
            ),
          ),
          Positioned(
            top: 60,
            right: 30,
            child: IslaImagenCustom(
              imagePath: 'assets/images/todas.png',
              numero: '4',
              nombre: 'Todas',
              width: 260,
              height: 190,
              onTap: () {
                // Navegar a la pantalla ExploreScreen al hacer click en "Todas"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExploreScreen()),
                );
              },
            ),
          ),
//otro boton 
          // Botón "Mis Plantas"
         // Botón "Mis Plantas" con imagen sobresaliente
// Botón "Mis Plantas" con imagen sobresaliente (lado derecho)
Positioned(
  bottom: 20,          // distancia al borde inferior
  right: 20,           // distancia al borde derecho
  child: Stack(
    alignment: Alignment.topCenter,
    children: [
      // Imagen que sobresale por encima del botón
      Positioned(
        top: -40,      // la eleva para que “flote” sobre el botón
        child: Image.asset(
          'assets/images/plantas.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
      // Botón circular/redondeado
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 10,
          shadowColor: Colors.black45,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TusPlantasScreen()),
          );
        },
        child: const Text(
          'Mis Plantas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      
    ],
  ),
),


          // Jardinerito animado con mensaje visible debajo
          TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(
              begin: _posicionActual,
              end: _posicionObjetivo,
            ),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Positioned(
                top: value.dy + _animationFloat.value,
                left: value.dx,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Image.asset(
                        'assets/images/jardinerito.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _mensajesCuriosos[_islaDestino],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBurbujas() {
    return [
      _Burbuja(left: 50, top: 100, size: 40),
      _Burbuja(right: 80, top: 200, size: 30),
      _Burbuja(left: 120, bottom: 150, size: 50),
      _Burbuja(right: 30, bottom: 100, size: 25),
      _Burbuja(left: 200, top: 300, size: 35),
    ];
  }
}

class IslaImagenCustom extends StatelessWidget {
  final String imagePath;
  final String numero;
  final String nombre;
  final double width;
  final double height;
  final VoidCallback onTap;

  const IslaImagenCustom({
    required this.imagePath,
    required this.numero,
    required this.nombre,
    required this.onTap,
    this.width = 200,
    this.height = 150,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                imagePath,
                width: width,
                height: height,
                fit: BoxFit.contain,
              ),
              Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Text(
                    numero,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
               
            ],
          ),
          const SizedBox(height: 5),
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Burbuja extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;

  const _Burbuja({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
        ),
      ),
    );
  }
}

class _ConexionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;

    final isla1 = Offset(30 + 100, size.height - 60 - 75);
    final isla2 = Offset(size.width - 30 - 100, size.height - 220 - 75);
    final isla3 = Offset(30 + 100, 270 + 75);
    final isla4 = Offset(size.width - 30 - 130, 60 + 95);

    final path1 = Path();
    path1.moveTo(isla1.dx, isla1.dy);
    path1.cubicTo(
      isla1.dx + 150, isla1.dy - 100,
      isla2.dx - 150, isla2.dy + 100,
      isla2.dx, isla2.dy,
    );
    canvas.drawPath(path1, paint);
    _drawPointsAlongPath(canvas, path1, dotPaint, 12);

    final path2 = Path();
    path2.moveTo(isla2.dx, isla2.dy);
    path2.cubicTo(
      isla2.dx - 150, isla2.dy - 100,
      isla3.dx + 150, isla3.dy + 100,
      isla3.dx, isla3.dy,
    );
    canvas.drawPath(path2, paint);
    _drawPointsAlongPath(canvas, path2, dotPaint, 12);

    final path3 = Path();
    path3.moveTo(isla3.dx, isla3.dy);
    path3.cubicTo(
      isla3.dx + 150, isla3.dy - 150,
      isla4.dx - 100, isla4.dy + 150,
      isla4.dx, isla4.dy,
    );
    canvas.drawPath(path3, paint);
    _drawPointsAlongPath(canvas, path3, dotPaint, 12);
  }

  void _drawPointsAlongPath(Canvas canvas, Path path, Paint paint, int pointsCount) {
    final metrics = path.computeMetrics().first;
    for (int i = 0 ; i < pointsCount; i++) {
final distance = metrics.length * i / (pointsCount - 1);
final pos = metrics.getTangentForOffset(distance)!.position;
canvas.drawCircle(pos, 6, paint);
}
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}