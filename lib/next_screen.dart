import 'package:flutter/material.dart';
import 'pantallas/explore_screen.dart';
import 'pantallas/tus_plantas_screen.dart';
import 'historial_screen.dart';
//import 'ayuda_screen.dart';

class NextScreen extends StatefulWidget {
  const NextScreen({super.key});

  @override
  NextScreenState createState() => NextScreenState();
}

class NextScreenState extends State<NextScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    ExploreScreen(),
    TusPlantasScreen(),
    HistorialScreen(),
    //AyudaScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Soy tu jardinerito", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final nextScreenState = context.findAncestorStateOfType<NextScreenState>();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parte superior: imagen del jardinerito y frase
          Container(
            height: 220, // Aumentamos el alto para dar más espacio a la imagen
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/plantas.png'), // Cambié el nombre de la imagen aquí
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "¿Qué deseas hacer hoy?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.black45),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30), // Separamos más los elementos

          // Parte inferior: filas de botones interactivos
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildCardButton('explorar.png', 'Explorar Plantas', 1, nextScreenState),
                _buildCardButton('misplantas.png', 'Mis Plantas', 2, nextScreenState),
                _buildCardButton('historial.png', 'Historial', 3, nextScreenState),
                _buildCardButton('jardinfoco.png', '¿Necesitas Ayuda?', 4, nextScreenState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Función para crear las tarjetas de cada botón
  Widget _buildCardButton(String image, String text, int index, NextScreenState? state) {
    return GestureDetector(
      onTap: () => state?.navigateToScreen(index),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10, // Aumentamos la elevación para dar más efecto de sombra
        shadowColor: Colors.black38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/$image',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 12), // Ajustamos el espaciado entre la imagen y el texto
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
