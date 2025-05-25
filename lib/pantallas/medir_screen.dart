import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class LuzRango {
  final double min;
  final double max;
  final String descripcion;
  final String estado;

  const LuzRango(this.min, this.max, this.descripcion, this.estado);
}

class MedirScreen extends StatefulWidget {
  final Map<String, dynamic>? planta;

  const MedirScreen({Key? key, this.planta}) : super(key: key);

  void guardarMedicion(BuildContext context, String tipo) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    await firestore.collection('historial').add({
      'planta': planta?['01_Nombre'] ?? 'Planta desconocida',
      'tipo': tipo,
      'fecha': now.toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medición "$tipo" guardada')),
    );
  }

  @override
  State<MedirScreen> createState() => _MedirScreenState();
}

class _MedirScreenState extends State<MedirScreen> {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? tempCharacteristic;
  BluetoothCharacteristic? humedadCharacteristic;
  BluetoothCharacteristic? luzCharacteristic;
  BluetoothCharacteristic? phCharacteristic;

  double _luzValue = 0.0;
  double _temperaturaValue = 0.0;
  double _humedadValue = 0.0;
  double _phValue = 0.0;

  static const Map<String, LuzRango> luzRanges = {
    'Luz solar directa': LuzRango(20000.0, 50000.0, 'Luz solar intensa', 'Alta'),
    'Luz solar parcial': LuzRango(10000.0, 20000.0, 'Luz solar moderada', 'Media'), 
    'Sombra parcial': LuzRango(5000.0, 10000.0, 'Sombra con algo de luz', 'Baja'),
    'Luz indirecta': LuzRango(1000.0, 5000.0, 'Luz difusa', 'Muy baja'),
    'Muy baja': LuzRango(0.0, 1000.0, 'Poca o ninguna luz', 'Insuficiente')
  };

  // UUIDs de los servicios y características
  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String tempCharUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String humedadCharUuid = "cba1d466-344c-4be3-ab3f-189f80dd7518";
  final String luzCharUuid = "fdcf4a3f-3fed-4ed2-84e6-04bbb9ae04d4";
  final String phCharUuid = "e7add780-b042-4876-aae1-112855353cc1";

  // Métodos BLE
  void _openBluetoothDialog() async { 
    try {
      final bluetoothStatus = await Permission.bluetooth.request();
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();
      final locationStatus = await Permission.location.request();

      if (!bluetoothStatus.isGranted || 
          !scanStatus.isGranted || 
          !connectStatus.isGranted ||
          !locationStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se necesitan todos los permisos para usar Bluetooth')),
        );
        return;
      }

      if (!await FlutterBluePlus.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth no está disponible en este dispositivo')),
        );
        return;
      }

      bool isBluetoothOn = await FlutterBluePlus.isOn;
      if (!isBluetoothOn) {
        try {
          await FlutterBluePlus.turnOn();
          await Future.delayed(const Duration(seconds: 1));
          isBluetoothOn = await FlutterBluePlus.isOn;
        } catch (e) {
          debugPrint('Error al intentar encender Bluetooth: $e');
        }
      }

      if (!isBluetoothOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo activar el Bluetooth. Por favor actívalo manualmente')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => BluetoothDeviceListDialog(
          onDeviceSelected: (device) async {
            await _connectToDevice(device);
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async { 
    try {
      await device.connect(autoConnect: false);
      List<BluetoothService> services = await device.discoverServices();
      
      for (var service in services) {
        if (service.uuid.toString() == serviceUuid) {
          for (var characteristic in service.characteristics) {
            switch (characteristic.uuid.toString()) {
              case "beb5483e-36e1-4688-b7f5-ea07361b26a8":
                tempCharacteristic = characteristic;
                break;
              case "cba1d466-344c-4be3-ab3f-189f80dd7518":
                humedadCharacteristic = characteristic;
                break;
              case "fdcf4a3f-3fed-4ed2-84e6-04bbb9ae04d4":
                luzCharacteristic = characteristic;
                break;
              case "e7add780-b042-4876-aae1-112855353cc1":
                phCharacteristic = characteristic;
                break;
            }
          }
        }
      }

      await _setupNotifications();

      setState(() {
        connectedDevice = device;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conectado a: ${device.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e')),
      );
    }
  }

  Future<void> _setupNotifications() async { 
    if (tempCharacteristic != null) {
      await tempCharacteristic!.setNotifyValue(true);
      tempCharacteristic!.onValueReceived.listen((value) {
        setState(() {
          _temperaturaValue = double.tryParse(String.fromCharCodes(value)) ?? 0.0;
        });
      });
    }

    if (humedadCharacteristic != null) {
      await humedadCharacteristic!.setNotifyValue(true);
      humedadCharacteristic!.onValueReceived.listen((value) {
        setState(() {
          _humedadValue = double.tryParse(String.fromCharCodes(value)) ?? 0.0;
        });
      });
    }

    if (luzCharacteristic != null) {
      await luzCharacteristic!.setNotifyValue(true);
      luzCharacteristic!.onValueReceived.listen((value) {
        setState(() {
          _luzValue = double.tryParse(String.fromCharCodes(value)) ?? 0.0;
        });
      });
    }

    if (phCharacteristic != null) {
      await phCharacteristic!.setNotifyValue(true);
      phCharacteristic!.onValueReceived.listen((value) {
        setState(() {
          _phValue = double.tryParse(String.fromCharCodes(value)) ?? 0.0;
        });
      });
    }
  }

  @override
  void dispose() {
    connectedDevice?.disconnect();
    super.dispose();
  }

  // Determina el estado de iluminación basado en los lux
  String _determinarEstadoLuz(double lux) {
    for (var entry in luzRanges.entries) {
      if (lux >= entry.value.min && lux <= entry.value.max) {
        return entry.value.estado;
      }
    }
    return 'Desconocido';
  }

  // Obtiene la descripción del rango de luz
  String _obtenerDescripcionLuz(double lux) {
    for (var entry in luzRanges.entries) {
      if (lux >= entry.value.min && lux <= entry.value.max) {
        return entry.value.descripcion;
      }
    }
    return 'Condición de luz desconocida';
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'Alta': return Colors.orange;
      case 'Media': return Colors.amber;
      case 'Baja': return Colors.lightBlue;
      case 'Muy baja': return Colors.blue;
      case 'Insuficiente': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  // Botón de Iluminación
  Widget _botonIluminacion(BuildContext context) {
    final estadoActual = _determinarEstadoLuz(_luzValue);
    final color = _obtenerColorEstado(estadoActual);

    return _botonSensor(
      context: context,
      icon: Icons.wb_sunny,
      label: 'Luz',
      color: color,
      valor: 0, // No mostramos valor numérico
      unidad: '',
      estado: estadoActual,
      onTap: () => _mostrarDetallesLuz(context),
    );
  }

  // Diálogo de Detalle para Luz
  void _mostrarDetallesLuz(BuildContext context) {
    final estadoActual = _determinarEstadoLuz(_luzValue);
    final descripcion = _obtenerDescripcionLuz(_luzValue);
    final recomendado = widget.planta?['04_Luz'] ?? 'Luz solar parcial';
    final rangoRecomendado = luzRanges[recomendado] ?? luzRanges['Luz solar parcial']!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado de Iluminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _itemDetalle('Estado actual:', estadoActual),
            _itemDetalle('Descripción:', descripcion),
            const SizedBox(height: 16),
            _itemDetalle('Recomendado:', rangoRecomendado.estado),
            _itemDetalle('Descripción:', rangoRecomendado.descripcion),
            const SizedBox(height: 16),
            Text(_obtenerConsejosLuz(estadoActual, rangoRecomendado.estado)),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _obtenerConsejosLuz(String estadoActual, String estadoRecomendado) {
    if (estadoActual == estadoRecomendado) {
      return 'La iluminación actual es ideal para esta planta.';
    }
    
    if (estadoActual == 'Insuficiente') {
      return '¡Atención! La planta no recibe suficiente luz. Considera moverla a un lugar más iluminado o usar luz artificial.';
    }
    
    if (estadoActual == 'Muy baja') {
      return 'La planta recibe poca luz. Sería beneficioso aumentar la exposición lumínica.';
    }
    
    if (estadoActual == 'Alta' && estadoRecomendado != 'Alta') {
      return 'La planta está recibiendo demasiada luz directa. Considera proporcionar algo de sombra.';
    }
    
    return 'Ajusta la iluminación según las necesidades específicas de la planta.';
  }

  // Botón Genérico Compacto
  Widget _botonSensor({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required double valor,
    required String unidad,
    required String estado,
    required VoidCallback onTap,
  }) {
    final simbolo = estado.contains('↓') ? '↓' : 
                   estado.contains('↑') ? '↑' : '✓';
    final colorEstado = estado.contains('↓') ? Colors.blue :
                       estado.contains('↑') ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
            Text('${valor.toStringAsFixed(1)} $unidad', 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(simbolo, style: TextStyle(fontSize: 20, color: colorEstado)),
          ],
        ),
      ),
    );
  }

  // Diálogo Genérico
  Widget _dialogoDetalle(
    BuildContext context, {
    required String titulo,
    required IconData icono,
    required Color color,
    required String valorActual,
    required String estado,
    required String recomendacion,
  }) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Text(titulo, style: const TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _itemDetalle('Valor actual:', valorActual),
            _itemDetalle('Estado:', estado),
            const SizedBox(height: 16),
            const Text('Recomendaciones:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(recomendacion, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // Helpers
  Widget _itemDetalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _determinarEstado(double valor, double min, double max) {
    if (valor < min) return 'Bajo (↓) - Fuera del rango ideal';
    if (valor > max) return 'Alto (↑) - Fuera del rango ideal';
    return 'Óptimo (✓) - En rango ideal';
  }

  String _obtenerConsejosTemperatura() {
    final temp = _temperaturaValue;
    final min = double.tryParse(widget.planta?['05_Temperatura']?['Mínima']?.toString() ?? '15') ?? 15;
    final max = double.tryParse(widget.planta?['05_Temperatura']?['Máxima']?.toString() ?? '30') ?? 30;
    
    if (temp < min) return 'Consejo: Proteger de corrientes frías y considerar trasladar a un lugar más cálido.';
    if (temp > max) return 'Consejo: Proporcionar sombra y aumentar riego para reducir temperatura.';
    return 'La temperatura actual es ideal para esta planta.';
  }

  @override
  Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(
    title: Text('Mediciones de $nombrePlanta'),
    backgroundColor: Colors.green.shade700,
  ),
  body: Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/arboles.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("¿Qué deseas medir?", style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: Icon(Icons.thermostat),
          label: Text('Temperatura'),
          onPressed: () => guardarMedicion(context, 'Temperatura'),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.light_mode),
          label: Text('Luz'),
          onPressed: () => guardarMedicion(context, 'Luz'),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.water_drop),
          label: Text('Humedad'),
          onPressed: () => guardarMedicion(context, 'Humedad'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Mediciones actuales',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _botonIluminacion(context),
            _botonSensor(
              context: context,
              icon: Icons.thermostat,
              label: 'Temp',
              color: Colors.red,
              valor: _temperaturaValue,
              unidad: '°C',
              estado: _determinarEstado(
                _temperaturaValue,
                double.tryParse(widget.planta?['05_Temperatura']?['Mínima']?.toString() ?? '15') ?? 15,
                double.tryParse(widget.planta?['05_Temperatura']?['Máxima']?.toString() ?? '30') ?? 30,
              ),
              onTap: () => _mostrarDetallesTemperatura(context),
            ),
            _botonSensor(
              context: context,
              icon: Icons.water_drop,
              label: 'Hum',
              color: Colors.blue,
              valor: _humedadValue,
              unidad: '%',
              estado: _determinarEstado(
                _humedadValue,
                double.tryParse(widget.planta?['06_HumedadRecomendada']?.split('-').first ?? '40') ?? 40,
                double.tryParse(widget.planta?['06_HumedadRecomendada']?.split('-').last ?? '70') ?? 70,
              ),
              onTap: () => _mostrarDetallesHumedad(context),
            ),
            _botonSensor(
              context: context,
              icon: Icons.opacity,
              label: 'pH',
              color: Colors.teal,
              valor: _phValue,
              unidad: '',
              estado: _determinarEstado(_phValue, 5.5, 7.0),
              onTap: () => _mostrarDetallesPh(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image(
              image: imagenPlanta.startsWith('assets/')
                  ? AssetImage(imagenPlanta) as ImageProvider
                  : NetworkImage(imagenPlanta),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: _openBluetoothDialog,
    icon: const Icon(Icons.bluetooth),
    label: Text(connectedDevice != null ? 'Conectado' : 'Conectar'),
    backgroundColor: connectedDevice != null ? Colors.green : Colors.grey,
  ),
);
