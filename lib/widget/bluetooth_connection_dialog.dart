import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConnectionDialog extends StatefulWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  const BluetoothConnectionDialog({super.key, required this.onDeviceSelected});

  @override
  State<BluetoothConnectionDialog> createState() => _BluetoothConnectionDialogState();
}

class _BluetoothConnectionDialogState extends State<BluetoothConnectionDialog> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> foundDevices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    setState(() => isScanning = true);
    foundDevices.clear();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!foundDevices.contains(r.device)) {
          setState(() {
            foundDevices.add(r.device);
          });
        }
      }
    });

    await Future.delayed(const Duration(seconds: 6));
    FlutterBluePlus.stopScan();
    setState(() => isScanning = false);
  }

  void _connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    await device.connect();
    widget.onDeviceSelected(device);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Selecciona tu dispositivo"),
      content: isScanning
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.maxFinite,
              height: 200,
              child: ListView(
                children: foundDevices
                    .where((d) => d.name.contains("ESP32"))
                    .map((device) => ListTile(
                          title: Text(device.name.isNotEmpty ? device.name : "Sin nombre"),
                          subtitle: Text(device.id.toString()),
                          trailing: const Icon(Icons.bluetooth_connected),
                          onTap: () => _connectToDevice(device),
                        ))
                    .toList(),
              ),
            ),
      actions: [
        TextButton(
            onPressed: () {
              FlutterBluePlus.stopScan();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"))
      ],
    );
  }
}
