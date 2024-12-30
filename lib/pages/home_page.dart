import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer;
import 'package:gal/gal.dart';
//import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool isCameraAvailable = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCameraController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (!isCameraAvailable) {
      return const Center(
        child: Text(
          'No camera available. Please connect a camera.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
              width: MediaQuery.of(context).size.width * 0.80,
              child: CameraPreview(
                cameraController!,
              ),
            ),
            IconButton(
              onPressed: () async {
                try {
                  if (cameraController != null &&
                      cameraController!.value.isInitialized) {
                    XFile picture = await cameraController!.takePicture();
                    Gal.putImage(picture.path);
                  } else {
                    developer.log('Camera is not initialized',
                        name: 'HomePage');
                  }
                } catch (e) {
                  developer.log('Error taking picture: ${e.toString()}',
                      name: 'HomePage');
                }
              },
              iconSize: 50,
              icon: const Icon(
                Icons.camera,
                color: Colors.red,
              ),
            ),
            /*IconButton(
              onPressed: () {},
              iconSize: 150,
              icon: const Icon(
                Icons.rectangle_outlined,
                color: Colors.blue,
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    try {
      // Fetch the list of available cameras
      cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        isCameraAvailable = true;
        // Prioritize external cameras if available
        CameraDescription selectedCamera = cameras.first;

        for (var camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.external) {
            selectedCamera = camera;
            break;
          }
        }

        // Initialize the selected camera
        cameraController = CameraController(
          selectedCamera,
          ResolutionPreset.high,
        );

        await cameraController?.initialize();

        if (mounted) {
          setState(() {});
        }
      } else {
        isCameraAvailable = false;
        developer.log('No cameras available', name: 'HomePage');
        setState(() {});
      }
    } catch (e) {
      isCameraAvailable = false;
      developer.log('Error initializing camera: ${e.toString()}',
          name: 'HomePage');
      setState(() {});
    }
  }
}

  /*Future<void> _triggerPythonFunctionality() async {
    // Replace this with your Python server's address and port
    const pythonServerUrl = 'http://127.0.0.1:5000/run';

    try {
      final response = await http.get(Uri.parse(pythonServerUrl));
      if (!mounted) return; // Check if the widget is still mounted before updating the UI

      if (response.statusCode == 200) {
        developer.log('Python response: ${response.body}', name: 'HomePage');
        // Show dialog only if the widget is mounted
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Python Script Response'),
              content: Text(response.body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        developer.log('Python script error: ${response.statusCode}', name: 'HomePage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error triggering Python script')),
          );
        }
      }
    } catch (e) {
      developer.log('Error triggering Python script: ${e.toString()}', name: 'HomePage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to communicate with Python')),
        );
      }
    }
  }
}*/