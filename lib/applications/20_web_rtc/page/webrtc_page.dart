import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/app/router.gr.dart';
import 'package:experiment_catalogue/applications/03_bmi_calc/cubit/bmi_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

//! ----page 2

@RoutePage()
class WebRtc20Page extends StatelessWidget {
  const WebRtc20Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BmiCubit()..getBmi(),
      child: const WebRtc20View(),
    );
  }
}

class WebRtc20View extends HookWidget {
  const WebRtc20View({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDeviceIdState = useState<String?>(null);
    final videoDevicesState = useState<List<MediaDeviceInfo>>([]);

    Future<void> getVideoDevices() async {
      final devices = await navigator.mediaDevices.enumerateDevices();
      final videoDevices = devices
          .where((d) => d.kind == 'videoinput')
          .toList()
          .fold<List<MediaDeviceInfo>>([], (acc, device) {
        // Deduplicate by deviceId
        if (!acc.any((d) => d.deviceId == device.deviceId)) {
          acc.add(device);
        }
        return acc;
      });

      if (videoDevices.isNotEmpty) {
        videoDevicesState.value = videoDevices;
        if (!videoDevicesState.value
            .any((d) => d.deviceId == selectedDeviceIdState.value)) {
          selectedDeviceIdState.value = videoDevices.first.deviceId;
        }
      } else {
        selectedDeviceIdState.value = null; // Reset if no device found
      }
    }

    void onCameraChanged(String? deviceId) {
      if (videoDevicesState.value.any((d) => d.deviceId == deviceId)) {
        selectedDeviceIdState.value = deviceId;
      }
    }

    useEffect(
      () {
        getVideoDevices();
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.purple[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              if (videoDevicesState.value.isNotEmpty)
                DropdownButton<String>(
                  value: selectedDeviceIdState.value,
                  items: videoDevicesState.value.map((device) {
                    return DropdownMenuItem(
                      value: device.deviceId,
                      child: Text(
                        device.label.isNotEmpty
                            ? device.label
                            : 'Unknown Camera',
                      ),
                    );
                  }).toList(),
                  onChanged: onCameraChanged,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (selectedDeviceIdState.value != null) {
                    context.router.push(
                        WebRtc20bRoute(deviceId: selectedDeviceIdState.value!));
                  }
                },
                child: const Text('To Page 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//! ----page 2
@RoutePage()
class WebRtc20bPage extends StatelessWidget {
  const WebRtc20bPage({super.key, required this.deviceId});
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BmiCubit()..getBmi(),
      child: WebRtc20bView(deviceId: deviceId),
    );
  }
}

class WebRtc20bView extends StatefulWidget {
  const WebRtc20bView({super.key, required this.deviceId});
  final String deviceId;

  @override
  State<WebRtc20bView> createState() => _WebRtc20bViewState();
}

class _WebRtc20bViewState extends State<WebRtc20bView> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  io.Socket? socket;
  String roomId = 'Room1';

  @override
  void initState() {
    super.initState();
    _initWebRTC();
    _initSocket();
  }

  Future<void> _initWebRTC() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _localStream = await navigator.mediaDevices.getUserMedia({
      //  'video': true,
      'video': {
        'deviceId': widget.deviceId, // Select the specific camera
        'facingMode':
            'user', // 'user' for front camera, 'environment' for back camera
        'width': 1280,
        'height': 720,
      },
      'audio': true,
    });

    _peerConnection = await createPeerConnection(
      {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      },
    );

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      socket?.emit('ice-candidate', {
        'roomId': roomId,
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    setState(() {
      _localRenderer.srcObject = _localStream;
    });
  }

  void _initSocket() {
    socket = io.io('http://localhost:3000/rtc', <String, dynamic>{
      'transports': ['websocket']
    });

    socket!.onConnect((_) {
      print('Connected to server');
      socket!.emit('join', roomId);
    });

    socket!.on('offer', (data) async {
      print('Received Offer');
      final description =
          RTCSessionDescription(data['sdp'] as String?, 'offer');
      await _peerConnection!.setRemoteDescription(description);
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      socket!.emit('answer', {'roomId': roomId, 'sdp': answer.toMap()});
    });

    socket!.on('answer', (data) async {
      print('Received Answer');
      final description =
          RTCSessionDescription(data['sdp'] as String?, 'answer');
      await _peerConnection!.setRemoteDescription(description);
    });

    socket!.on('ice-candidate', (data) async {
      print('Received ICE Candidate');
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'] as String?,
        data['candidate']['sdpMid'] as String?,
        data['candidate']['sdpMLineIndex'] as int?,
      );
      await _peerConnection!.addCandidate(candidate);
    });
  }

  void _startCall() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    socket!.emit('offer', {'roomId': roomId, 'sdp': offer.toMap()});
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BmiCubit, BmiState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: Colors.purple[100],
          body: Column(
            children: [
              Expanded(child: RTCVideoView(_localRenderer)),
              Expanded(child: RTCVideoView(_remoteRenderer)),
              ElevatedButton(
                onPressed: _startCall,
                child: const Text('Start Call'),
              )
            ],
          ),
        );
      },
    );
  }
}
