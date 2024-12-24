import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer;

import 'package:gal/gal.dart';

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
              height: MediaQuery.of(context).size.height * 0.30,
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
        CameraDescription selectedCamera =
            cameras.first; // Default to the first camera

        for (var camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.external) {
            selectedCamera = camera; // Select the external camera
            break;
          }
        }

        // Initialize the selected camera
        cameraController = CameraController(
          selectedCamera,
          ResolutionPreset.high, // Use high resolution
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
