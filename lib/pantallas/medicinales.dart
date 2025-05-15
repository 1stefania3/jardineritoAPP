import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicinalesScreen extends StatefulWidget {
  const MedicinalesScreen({super.key});

  @override
  State<MedicinalesScreen> createState() => _MedicinalesScreenState();
}

class _MedicinalesScreenState extends State<MedicinalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPlants = [];
  List<Map<String, dynamic>> _filteredPlants = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicinalPlants();
    _searchController.addListener(_filterPlants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll('"', '')
        .trim();
  }

  void _filterPlants() {
    final query = normalizeText(_searchController.text);
    setState(() {
      _filteredPlants = _allPlants.where((plant) {
        final name = normalizeText(plant['01_Nombre'] ?? '');
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchMedicinalPlants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Plantas').get();

      final plants = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filtrar solo plantas medicinales
      final medicinalPlants = plants.where((plant) {
        final tipo = (plant['tipo'] ?? '').toString().toLowerCase();
        return tipo == 'medicinal';
      }).toList();

      setState(() {
        _allPlants = List<Map<String, dynamic>>.from(medicinalPlants);
        _filteredPlants = List<Map<String, dynamic>>.from(medicinalPlants);
      });
    } catch (e) {
      print('Error al obtener plantas medicinales: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Plantas Medicinales'),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
  child: CustomPaint(
    painter: BackgroundPainterMedicinal(),
  ),
),

          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: _filteredPlants.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No hay plantas medicinales disponibles.'
                              : 'No se encontraron plantas para "${_searchController.text}".',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _filteredPlants.length,
                          itemBuilder: (context, index) {
                            final plant = _filteredPlants[index];
                            return _buildPlantCard(plant);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar planta medicinal...',
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          hintStyle: const TextStyle(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () => _showPlantDetails(plant),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  plant['13_imagen'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                plant['01_Nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.green,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showPlantDetails(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    plant['13_imagen'] ?? '',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  plant['01_Nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  plant['02_Descripción'] ?? 'Sin descripción disponible',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Añadir a Mis Plantas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      final newDoc = FirebaseFirestore.instance
                          .collection('MisPlantas')
                          .doc();
                      final plantWithId = Map<String, dynamic>.from(plant);
                      plantWithId['id'] = newDoc.id;
                      await newDoc.set(plantWithId);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${plant['01_Nombre']} añadida a Mis Plantas',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BackgroundPainterMedicinal extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightGreen = Paint()..color = Colors.green.shade100;
    final mediumGreen = Paint()..color = Colors.green.shade300;
    final darkGreen = Paint()..color = Colors.green.shade600;

    // Fondo degradado suave
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [Colors.green.shade50, Colors.green.shade200],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final paintGradient = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paintGradient);

    // Formas orgánicas
    final path1 = Path();
    path1.moveTo(0, size.height * 0.35);
    path1.quadraticBezierTo(
        size.width * 0.3, size.height * 0.25, size.width * 0.55, size.height * 0.4);
    path1.quadraticBezierTo(
        size.width * 0.75, size.height * 0.55, size.width, size.height * 0.35);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, mediumGreen);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.55);
    path2.quadraticBezierTo(
        size.width * 0.2, size.height * 0.45, size.width * 0.45, size.height * 0.55);
    path2.quadraticBezierTo(
        size.width * 0.7, size.height * 0.7, size.width, size.height * 0.55);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, lightGreen);

    final path3 = Path();
    path3.moveTo(0, size.height * 0.8);
    path3.quadraticBezierTo(
        size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.8);
    path3.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, darkGreen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
