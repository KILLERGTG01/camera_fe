import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer;
import '../../../core/widgets/base_scaffold.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool isCameraAvailable = true;
  int selectedCameraIndex = 0;
  bool isRecording = false;

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
    return BaseScaffold(
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
              height: MediaQuery.of(context).size.height * 0.70,
              width: MediaQuery.of(context).size.width * 0.70,
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
                      if (isRecording) {
                        // Stop recording
                        XFile videoFile =
                            await cameraController!.stopVideoRecording();
                        developer.log(
                          'Video recorded: ${videoFile.path}',
                          name: 'VideoPage',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Video saved: ${videoFile.path}'),
                          ),
                        );
                        setState(() {
                          isRecording = false;
                        });
                      } else {
                        // Start recording
                        await cameraController!.startVideoRecording();
                        developer.log('Started recording', name: 'VideoPage');
                        setState(() {
                          isRecording = true;
                        });
                      }
                    } catch (e) {
                      developer.log('Error recording video: $e',
                          name: 'VideoPage');
                    }
                  },
                  iconSize: 50,
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.videocam,
                    color: isRecording ? Colors.red : Colors.blue,
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
          ResolutionPreset.max,
          enableAudio: true, // Enable audio for video recording
        );

        await cameraController?.initialize();

        if (mounted) {
          setState(() {});
        }
      } else {
        isCameraAvailable = false;
        developer.log('No cameras available', name: 'VideoPage');
        setState(() {});
      }
    } catch (e) {
      isCameraAvailable = false;
      developer.log('Error initializing camera: ${e.toString()}',
          name: 'VideoPage');
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
