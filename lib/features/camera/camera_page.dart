import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer;

import 'package:gal/gal.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool isCameraAvailable = true;
  int selectedCameraIndex = 0; // Track the currently selected camera index

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    try {
                      if (cameraController != null &&
                          cameraController!.value.isInitialized) {
                        XFile picture = await cameraController!.takePicture();
                        Gal.putImage(picture.path);
                      } else {
                        developer.log('Camera is not initialized',
                            name: 'CameraPage');
                      }
                    } catch (e) {
                      developer.log('Error taking picture: ${e.toString()}',
                          name: 'CameraPage');
                    }
                  },
                  iconSize: 50,
                  icon: const Icon(
                    Icons.camera,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: _switchCamera, // Switch camera on button press
                  iconSize: 50,
                  icon: const Icon(
                    Icons.switch_camera,
                    color: Colors.blue,
                  ),
                ),
              ],
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

        // Select the current camera by index
        CameraDescription selectedCamera = cameras[selectedCameraIndex];

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
        developer.log('No cameras available', name: 'CameraPage');
        setState(() {});
      }
    } catch (e) {
      isCameraAvailable = false;
      developer.log('Error initializing camera: ${e.toString()}',
          name: 'CameraPage');
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.isNotEmpty) {
      selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;

      // Dispose the current camera controller before switching
      await cameraController?.dispose();

      // Setup the new camera controller
      await _setupCameraController();
    }
  }
}
