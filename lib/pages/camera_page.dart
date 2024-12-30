import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late WebSocketChannel _channel;
  bool _isStreaming = false;
  String _statusMessage = '';
  Map<String, dynamic>? _frameInfo;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.29.205:5001/socket.io/'),
    );

    _channel.stream.listen(
      (message) {
        final data = _parseMessage(message);
        if (data != null) {
          if (data.containsKey('frame')) {
            setState(() {
              _frameInfo = data['frame'];
              _isStreaming = true;
            });
          } else if (data.containsKey('error')) {
            setState(() {
              _statusMessage = data['error']['message'];
              _isStreaming = false;
            });
          }
        }
      },
      onError: (error) {
        setState(() {
          _statusMessage = 'WebSocket error: $error';
        });
      },
      onDone: () {
        setState(() {
          _isStreaming = false;
          _statusMessage = 'WebSocket connection closed.';
        });
      },
    );
  }

  Map<String, dynamic>? _parseMessage(String message) {
    try {
      return Map<String, dynamic>.from(jsonDecode(message));
    } catch (_) {
      return null;
    }
  }

  void _startCamera() {
    _channel.sink
        .add(jsonEncode({'event': 'start_camera', 'camera_id': 'CAMERA_ID'}));
  }

  void _stopCamera() {
    _channel.sink
        .add(jsonEncode({'event': 'stop_camera', 'camera_id': 'CAMERA_ID'}));
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Stream'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: _isStreaming && _frameInfo != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Camera is streaming...',
                              style: TextStyle(color: Colors.green)),
                          Text(
                              'Resolution: ${_frameInfo?['width']}x${_frameInfo?['height']}',
                              style: const TextStyle(color: Colors.white)),
                          Text('Data Size: ${_frameInfo?['data_size']} bytes',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text('Camera is not streaming.',
                          style: TextStyle(color: Colors.red)),
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: _startCamera, child: const Text('Start')),
              ElevatedButton(onPressed: _stopCamera, child: const Text('Stop')),
            ],
          ),
          if (_statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_statusMessage,
                  style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
