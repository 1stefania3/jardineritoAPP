import 'package:flutter/material.dart';
import 'dart:math';

class PantallaInicio extends StatefulWidget {
  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _textController;
  late Animation<Offset> _textOffset;
  late Animation<double> _textFade;

  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_logoController);

    _textController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _textOffset = Tween<Offset>(
      begin: Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _confettiController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _logoController.forward();
    Future.delayed(Duration(milliseconds: 600), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.green[50],
        body: Stack(
  children: [
    // FONDO DE IMAGEN
    Positioned.fill(
      child: Image.asset(
        'assets/images/fondo.jpg',
        fit: BoxFit.cover,
      ),
    ),
        
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return ConfettiBackground(controllerValue: _confettiController.value, size: size);
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Image.asset('assets/images/logo.png', width: 200),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _textOffset,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Text(
                            '¡Gracias por confiar en Planti-Bot!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.green[900],
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tu compañero verde para cuidar tus plantas.',
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.green[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: AnimatedScale(
                              scale: 1,
                              duration: Duration(milliseconds: 300),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green[700]!, Colors.green[400]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.eco_rounded, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Comienza la experiencia',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
    );
  }
}

class ConfettiBackground extends StatelessWidget {
  final double controllerValue;
  final Size size;

  const ConfettiBackground({required this.controllerValue, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConfettiPainter(controllerValue, size),
      child: Container(),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double value;
  final Size size;
  final Paint paintConfetti = Paint();

  ConfettiPainter(this.value, this.size);

  final List<Color> colors = [
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.white70,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double time = value * 2 * pi;
    final int count = 25;

    for (int i = 0; i < count; i++) {
      final double dx = sin(time + i) * 150 + size.width / 2;
      final double dy = size.height - ((time * 100 + i * 35) % size.height);

      paintConfetti.color = colors[i % colors.length].withOpacity(0.7);
      canvas.drawCircle(Offset(dx, dy), 6 + (i % 3).toDouble(), paintConfetti);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
