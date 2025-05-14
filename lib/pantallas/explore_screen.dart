import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPlants = [];
  List<Map<String, dynamic>> _filteredPlants = [];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchPlants();
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
        final type = plant['tipo'] ?? '';
        final matchesName = name.contains(query);
        final matchesType = _selectedType == null || type == _selectedType;
        return matchesName && matchesType;
      }).toList();
    });
  }

  Future<void> _fetchPlants() async {
    final snapshot = await FirebaseFirestore.instance.collection('Plantas').get();
    final plants = snapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      _allPlants = plants;
      _filteredPlants = plants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 4.0,
              minScale: 1.0,
              child: CustomPaint(
                painter: BackgroundPainter(),
                child: _buildCanvas(),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 10),
                _buildTypeFilters(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredPlants.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          childAspectRatio: 0.75,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (context, index) {
          final plant = _filteredPlants[index];
          return _buildPlantCardGrid(plant);
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar planta por nombre...',
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildTypeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Ornamental', 'Medicinal', 'Árbol'].map((type) {
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              selectedColor: Colors.green.shade200,
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type : null;
                  _filterPlants();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlantCardGrid(Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () => _showPlantDetailsModern(plant),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  plant['13_imagen'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                plant['01_Nombre'] ?? 'Sin nombre',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlantDetailsModern(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  plant['13_imagen'] ?? '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                plant['01_Nombre'] ?? 'Sin nombre',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                plant['02_Descripción'] ?? 'Sin descripción',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final newDoc = FirebaseFirestore.instance.collection('MisPlantas').doc();
                  final newId = newDoc.id;
                  final plantWithId = Map<String, dynamic>.from(plant);
                  plantWithId['id'] = newId;
                  await newDoc.set(plantWithId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${plant['01_Nombre']} añadida a Mis Plantas')),
                  );
                },
                child: const Text('Añadir a Mis Plantas'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade50
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
