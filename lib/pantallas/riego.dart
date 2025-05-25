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
  late final String _docId;

  late int frecuenciaRiegoDias;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _docId = _generarDocId();

    // Obtener frecuencia de riego desde el campo '08_Riego' de la planta, por defecto 3 días
    frecuenciaRiegoDias = int.tryParse(widget.planta['08_Riego']?.toString() ?? '') ?? 3;

    _fetchRiegoData();
  }

  String _generarDocId() {
    String nombreSeguro = widget.planta['01_Nombre'].toString().replaceAll(' ', '_');
    return '${widget.planta['id']}_$nombreSeguro';
  }

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
    } else {
      setState(() {
        _regadoData = {};
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
        await docRef.update({
          'historial': FieldValue.arrayUnion([nuevoRegistro]),
        });
      } else {
        await docRef.set({
          'idPlanta': widget.planta['id'],
          'nombrePlanta': widget.planta['01_Nombre'],
          'historial': [nuevoRegistro],
        });
      }

      await _fetchRiegoData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(regado ? 'Riego registrado con éxito!' : 'Registro de no riego guardado'),
          backgroundColor: regado ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error al registrar el riego: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al registrar el riego. Intenta de nuevo.')),
      );
    }
  }

  // Función para calcular días en que debe regarse según la frecuencia, desde el último riego
  Set<DateTime> _calcularDiasDeRiego() {
    Set<DateTime> diasRiego = {};

    if (_regadoData.isEmpty) {
      // Si no hay riegos, sugerir que se riegue hoy
      diasRiego.add(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));
      return diasRiego;
    }

    // Obtener la fecha más reciente en que se regó (true)
    List<DateTime> fechasRegadas = _regadoData.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (fechasRegadas.isEmpty) {
      // No hay riego registrado, sugerir hoy
      diasRiego.add(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));
      return diasRiego;
    }

    fechasRegadas.sort((a, b) => a.compareTo(b));
    DateTime ultimaFecha = fechasRegadas.last;

    // Vamos a marcar como días de riego cada fecha sumando la frecuencia a la última fecha
    // por un rango de 30 días hacia adelante para el calendario
    DateTime current = ultimaFecha;
    DateTime limite = DateTime.now().add(const Duration(days: 30));

    while (current.isBefore(limite)) {
      diasRiego.add(DateTime(current.year, current.month, current.day));
      current = current.add(Duration(days: frecuenciaRiegoDias));
    }

    return diasRiego;
  }

  @override
  Widget build(BuildContext context) {
    final diasRiego = _calcularDiasDeRiego();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 4,
        title: Text(
          'Riego: ${widget.planta['01_Nombre']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blueAccent, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Frecuencia de riego: cada $frecuenciaRiegoDias día${frecuenciaRiegoDias > 1 ? "s" : ""}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent.shade200,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 243, 2, 2).withOpacity(0.6),
                      spreadRadius: 1,
                      blurRadius: 8,
                    ),
                  ],
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.8),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.blueAccent.shade400,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(

              defaultBuilder: (context, date, _) {
  final dateKey = DateTime(date.year, date.month, date.day);
  final bool? regado = _regadoData[dateKey];
  final bool sugerido = diasRiego.contains(dateKey);

  Color bgColor;
  Color borderColor;
  Color textColor;

  if (regado == true) {
    bgColor = Colors.green.shade100;
    borderColor = Colors.green.shade400;
    textColor = Colors.green.shade700;
  } else if (regado == false) {
    bgColor = Colors.red.shade100;
    borderColor = Colors.red.shade400;
    textColor = Colors.red.shade700;
  } else {
    bgColor = Colors.white;
    borderColor = Colors.transparent;
    textColor = Colors.black87;
  }

  return Stack(
    children: [
      Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      if (sugerido && regado != true)
        Positioned(
          bottom: 6,
          right: 6,
          child: Icon(Icons.water_drop, size: 14, color: Colors.blueAccent),
        ),
    ],
  );
},

               todayBuilder: (context, date, _) {
  final dateKey = DateTime(date.year, date.month, date.day);
  final bool regado = _regadoData[dateKey] ?? false;
  final bool sugerido = diasRiego.contains(dateKey);

  return Stack(
    children: [
      Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: regado ? Colors.green.shade600 : Colors.blueAccent.shade700,
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: regado ? Colors.green.shade900 : const Color.fromARGB(255, 25, 90, 204),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      if (sugerido && !regado)
        Positioned(
          bottom: 6,
          right: 6,
          child: Icon(Icons.water_drop, size: 14, color: Colors.blue),
        ),
    ],
  );
},

                selectedBuilder: (context, date, _) {
                  final dateKey = DateTime(date.year, date.month, date.day);
                  final bool regado = _regadoData[dateKey] ?? false;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.7),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black54),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _botonAnimado(
                  label: 'Registrar Riego',
                  color: Colors.green.shade600,
                  icon: Icons.water_drop,
                  onPressed: () => _registrarRiego(true),
                ),
                const SizedBox(width: 20),
                _botonAnimado(
                  label: 'No Regado',
                  color: Colors.red.shade600,
                  icon: Icons.block,
                  onPressed: () => _registrarRiego(false),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Estado para ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}: '
              '${(_regadoData[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? false) ? "Regado" : "No Regado"}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Historial de Riegos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
  child: _regadoData.isEmpty
      ? const Center(
          child: Text(
            'No hay registros aún.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        )
      : ListView(
          children: _regadoData.entries.map((entry) {
            final date = entry.key;
            final regado = entry.value;
            return ListTile(
              leading: Icon(
                regado ? Icons.water_drop : Icons.block,
                color: regado ? Colors.blue : Colors.red,
              ),
              title: Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(regado ? 'Regado' : 'No Regado'),
            );
          }).toList(),
        ),
),

          ],
        ),
      ),
    );
  }


  Widget _botonAnimado({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: color.withOpacity(0.5),
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    );
  }
}
