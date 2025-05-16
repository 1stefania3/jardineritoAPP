import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ArbolesScreen extends StatefulWidget {
  const ArbolesScreen({Key? key}) : super(key: key);

  @override
  State<ArbolesScreen> createState() => _ArbolesScreenState();
}

class _ArbolesScreenState extends State<ArbolesScreen> {
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
      final snapshot = await FirebaseFirestore.instance
          .collection('Plantas')
          .where('tipo', isEqualTo: 'Árbol')
          .get();

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/arboles.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 30),
              _buildTitleWidget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: _filteredPlants.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No hay árboles disponibles.'
                              : 'No se encontraron árboles para "${_searchController.text}".',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
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

  Widget _buildTitleWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/titulo.jpg',
          width: 280,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(40),
      color: Colors.white.withOpacity(0.9),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar árbol por nombre...',
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          hintStyle: const TextStyle(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () => _showPlantDetails(context, plant),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/acuarelaverde.jpg'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: Colors.green.shade700.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                plant['13_imagen'] ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Fondo oscuro transparente
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    plant['01_Nombre'] ?? 'Sylverna',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CinzelDecorative',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plant['02_Descripción']?.toString().split('.').first ??
                        'Un árbol místico con hojas danzantes.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

 void _showPlantDetails(BuildContext context, Map<String, dynamic> plant) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          String imageUrl = (plant['13_imagen'] ?? '').toString().trim();
          String title = (plant['fantasy_name'] ?? plant['01_Nombre'] ?? 'Sin nombre').toString();
          String description = (plant['02_Descripción'] ?? 'Sin descripción').toString();

          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              image: const DecorationImage(
                image: AssetImage('assets/images/acuarelaverde.jpg'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: Colors.green.shade700.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              // Fondo oscuro semi-transparente para el contenido
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
                              )
                            : const Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'CinzelDecorative',
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRowWhite("Ubicación ideal", plant['03_UbicaciónIdeal']?.toString()),
                    _buildInfoRowWhite("Luz", plant['04_Luz']?.toString()),
                    _buildInfoRowWhite("Temperatura", plant['05_Temperatura']?.toString()),
                    _buildInfoRowWhite("Cuidados", plant['12_Cuidados']?.toString()),
                    _buildInfoRowWhite("Humedad", plant['06_HumedadRecomendada']?.toString()),
                    _buildInfoRowWhite("Maceta", plant['07_Maceta']?.toString()),
                    _buildInfoRowWhite("Frecuencia de poda", plant['09_FrecuenciaPoda']?.toString()),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.favorite_border, size: 24),
                        label: const Text(
                          'Añadir a Mis Plantas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          try {
                            final newDoc = FirebaseFirestore.instance.collection('MisPlantas').doc();
                            final newId = newDoc.id;
                            final plantWithId = Map<String, dynamic>.from(plant);
                            plantWithId['id'] = newId;
                            await newDoc.set(plantWithId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Añadido a Mis Plantas')),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al añadir planta: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          shadowColor: Colors.greenAccent.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildInfoRowWhite(String label, String? value) {
  if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}


}
