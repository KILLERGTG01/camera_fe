import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraState {
  final bool isLoading;
  final bool isInitialized;
  final bool isCameraOpen;
  final Map<String, dynamic>? frameInfo;
  final String statusMessage;

  CameraState({
    required this.isLoading,
    required this.isInitialized,
    required this.isCameraOpen,
    this.frameInfo,
    this.statusMessage = '',
  });

  CameraState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? isCameraOpen,
    Map<String, dynamic>? frameInfo,
    String? statusMessage,
  }) {
    return CameraState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isCameraOpen: isCameraOpen ?? this.isCameraOpen,
      frameInfo: frameInfo ?? this.frameInfo,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier()
      : super(CameraState(
          isLoading: false,
          isInitialized: false,
          isCameraOpen: false,
        ));

  Timer? _pollingTimer;
  WebSocketChannel? _webSocketChannel;

  Future<void> initializeCamera(String apiUrl) async {
    state = state.copyWith(isLoading: true, statusMessage: '');
    try {
      final response = await http.post(Uri.parse('$apiUrl/init'));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          state = state.copyWith(
            isInitialized: true,
            statusMessage: 'Camera initialized successfully.',
          );
        } else {
          state = state.copyWith(
            statusMessage: result['message'] ?? 'Failed to initialize camera.',
          );
        }
      } else {
        state = state.copyWith(
          statusMessage: 'Error: Unable to communicate with the server.',
        );
      }
    } catch (e) {
      state = state.copyWith(statusMessage: 'Exception: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> startCamera(String wsUrl) async {
    try {
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      state = state.copyWith(isCameraOpen: true);

      _webSocketChannel!.stream.listen((data) {
        final frameInfo = json.decode(data);
        state = state.copyWith(frameInfo: frameInfo);
      }, onError: (error) {
        state = state.copyWith(statusMessage: 'WebSocket Error: $error');
      });
    } catch (e) {
      state = state.copyWith(statusMessage: 'Exception: $e');
    }
  }

  void startPolling(String wsUrl) {
    _pollingTimer?.cancel();
    startCamera(wsUrl); // Start camera immediately
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await startCamera(wsUrl);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _webSocketChannel?.sink.close();
    state = state.copyWith(isCameraOpen: false, frameInfo: null);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _webSocketChannel?.sink.close();
    super.dispose();
  }
}

final cameraNotifierProvider =
    StateNotifierProvider<CameraNotifier, CameraState>(
  (ref) => CameraNotifier(),
);
