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
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchPlants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Plantas').get();

      final plants = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _allPlants = List<Map<String, dynamic>>.from(plants);
        _filteredPlants = List<Map<String, dynamic>>.from(plants);
      });
    } catch (e) {
      print('Error al obtener plantas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar Plantas'),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredPlants.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 columnas estilo feed instagram
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1, // cuadrado perfecto
        ),
        itemBuilder: (context, index) {
          final plant = _filteredPlants[index];
          return GestureDetector(
            onTap: () => _showPlantDetailsModal(plant),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                plant['13_imagen'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
              ),
            ),
          );
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

  void _showPlantDetailsModal(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    plant['13_imagen'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  plant['01_Nombre'] ?? 'Sin nombre',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  plant['02_Descripción'] ?? 'Sin descripción',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
                // Puedes agregar más campos importantes aquí, por ejemplo:
                if ((plant['03_Ubicación'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Ubicación ideal: ${plant['03_Ubicación']}')),
                    ],
                  ),
                ],
                if ((plant['04_Luz'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Luz: ${plant['04_Luz']}')),
                    ],
                  ),
                ],
                if ((plant['05_Temperatura'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.thermostat, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Temperatura ideal: ${plant['05_Temperatura']}')),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final newDoc = FirebaseFirestore.instance.collection('MisPlantas').doc();
                    final newId = newDoc.id;
                    final plantWithId = Map<String, dynamic>.from(plant);
                    plantWithId['id'] = newId;
                    await newDoc.set(plantWithId);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${plant['01_Nombre']} añadida a Mis Plantas'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Añadir a Mis Favoritos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
