import 'package:flutter/material.dart';
import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NetworkInfo _networkInfo = NetworkInfo();
  String localIp = 'Unknown';
  List<String> networkDevices = [];
  FlutterMdnsPlugin? _mdnsPlugin;
  bool cameraFound = false;
  String cameraHostName = '';
  bool isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeNetwork();
  }

  @override
  void dispose() {
    _stopMdnsDiscovery();
    super.dispose();
  }

  Future<void> _initializeNetwork() async {
    try {
      final ip = await _networkInfo.getWifiIP(); // Fetch the local IP
      if (mounted) {
        setState(() {
          localIp = ip ?? 'Unknown';
        });
        _startMdnsDiscovery();
      }
    } catch (e) {
      developer.log('Failed to get local IP: $e', name: 'HomePage');
    }
  }

  void _startMdnsDiscovery() {
    _mdnsPlugin = FlutterMdnsPlugin(
      discoveryCallbacks: DiscoveryCallbacks(
        onDiscoveryStarted: () {
          developer.log('Discovery started', name: 'HomePage');
        },
        onDiscoveryStopped: () {
          developer.log('Discovery stopped', name: 'HomePage');
        },
        onDiscovered: (ServiceInfo serviceInfo) {
          developer.log('Service discovered: ${serviceInfo.name}',
              name: 'HomePage');
        },
        onResolved: (ServiceInfo serviceInfo) {
          if (serviceInfo.name.contains('camera')) {
            if (mounted) {
              setState(() {
                cameraFound = true;
                cameraHostName = serviceInfo.hostName;
              });
            }
            developer.log('Camera resolved at host: $cameraHostName',
                name: 'HomePage');
          }
        },
      ),
    );

    _mdnsPlugin?.startDiscovery("_http._tcp");
  }

  void _stopMdnsDiscovery() {
    _mdnsPlugin?.stopDiscovery();
  }

  Future<void> _savePhoto(String photoPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${directory.path}/$fileName';

    try {
      await File(photoPath).copy(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo saved at $filePath')),
        );
      }
    } catch (e) {
      developer.log('Failed to save photo: $e', name: 'HomePage');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraFound && isStreaming) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                'Camera Stream Placeholder',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Positioned(
              bottom: 20,
              child: IconButton(
                iconSize: 70,
                icon: const Icon(
                  Icons.camera,
                  color: Colors.red,
                ),
                onPressed: () {
                  // Replace the placeholder code with actual camera capture
                  final placeholderPath = '/path/to/captured/photo.jpg';
                  _savePhoto(placeholderPath);
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Cameras'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Local IP: $localIp',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: networkDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Device Found: ${networkDevices[index]}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                networkDevices.clear();
                cameraFound = false;
                isStreaming = false;
              });
              _startMdnsDiscovery();
            },
            child: const Text('Scan Network'),
          ),
        ],
      ),
    );
  }
}
