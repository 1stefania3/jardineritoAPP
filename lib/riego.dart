import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiegoScreen extends StatefulWidget {
  final Map<String, dynamic> planta;

  const RiegoScreen({super.key, required this.planta});

  @override
  _RiegoScreenState createState() => _RiegoScreenState();
}

class _RiegoScreenState extends State<RiegoScreen> {
  late DateTime _selectedDay;
  Map<DateTime, bool> _regadoData = {};

  late final String _docId; // 🔥 Nuevo: id único para la planta en riego

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _docId = _generarDocId(); // Inicializamos el id del documento
    _fetchRiegoData();
  }

  // 🔥 Generar id seguro para Firestore combinando idPlanta + nombrePlanta
  String _generarDocId() {
    String nombreSeguro = widget.planta['01_Nombre'].toString().replaceAll(' ', '_');
    return '${widget.planta['id']}_$nombreSeguro';
  }

  // 🔥 Cargar historial del documento único de la planta
  Future<void> _fetchRiegoData() async {
    final docRef = FirebaseFirestore.instance.collection('Riego').doc(_docId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final List<dynamic> historial = data['historial'] ?? [];

      Map<DateTime, bool> tempRiegoData = {};
      for (var registro in historial) {
        DateTime date = (registro['fecha'] as Timestamp).toDate();
        bool regado = registro['regado'];
        tempRiegoData[DateTime(date.year, date.month, date.day)] = regado;
      }

      setState(() {
        _regadoData = tempRiegoData;
      });
    }
  }

  Future<void> _registrarRiego(bool regado) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('Riego').doc(_docId);
      final docSnapshot = await docRef.get();

      Map<String, dynamic> nuevoRegistro = {
        'fecha': Timestamp.fromDate(_selectedDay),
        'regado': regado,
      };

      if (docSnapshot.exists) {
        // 👉 Ya existe el documento: actualizamos historial
        await docRef.update({
          'historial': FieldValue.arrayUnion([nuevoRegistro]),
        });
      } else {
        // 👉 No existe: creamos documento nuevo
        await docRef.set({
          'idPlanta': widget.planta['id'],
          'nombrePlanta': widget.planta['01_Nombre'],
          'historial': [nuevoRegistro],
        });
      }

      // Recargamos datos después de registrar
      await _fetchRiegoData();
    } catch (e) {
      print('Error al registrar el riego: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error al registrar el riego. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riego: ${widget.planta['01_Nombre']}'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _selectedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, events) {
                  final isRegado = _regadoData[DateTime(date.year, date.month, date.day)] ?? false;
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: isRegado ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, date, events) {
                  final isRegado = _regadoData[DateTime(date.year, date.month, date.day)] ?? false;
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: isRegado ? Colors.green : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _registrarRiego(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Registrar Riego'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _registrarRiego(false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('No Regado'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Estado para ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}: '
              '${(_regadoData[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? false) ? "Regado" : "No Regado"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Historial de Riegos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _regadoData.isEmpty
                  ? const Center(child: Text('No hay registros aún.'))
                  : ListView(
                      children: _regadoData.entries
                          .toList()
                          .sorted((a, b) => b.key.compareTo(a.key))
                          .map((entry) {
                        DateTime date = entry.key;
                        bool regado = entry.value;
                        return ListTile(
                          leading: Icon(
                            regado ? Icons.check_circle : Icons.cancel,
                            color: regado ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(regado ? 'Regado' : 'No regado'),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 Extensión para ordenar mapas fácilmente
extension SortedMap<K, V> on List<MapEntry<K, V>> {
  List<MapEntry<K, V>> sorted(Comparator<MapEntry<K, V>> compare) {
    sort(compare);
    return this;
  }
}
