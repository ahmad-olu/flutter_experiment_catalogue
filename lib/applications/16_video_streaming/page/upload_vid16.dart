import 'dart:convert' show jsonDecode;
import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/app/router.gr.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:image_picker/image_picker.dart';

@RoutePage()
class UploadVideo16Page extends StatelessWidget {
  const UploadVideo16Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const UploadVideo16View();
  }
}

class UploadResponse {
  UploadResponse({required this.videoId, required this.message});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      videoId: json['video_id'] as String,
      message: json['message'] as String,
    );
  }
  final String videoId;
  final String message;
}

class UploadVideo16View extends StatefulWidget {
  const UploadVideo16View({super.key});

  @override
  State<UploadVideo16View> createState() => _UploadVideo16ViewState();
}

class _UploadVideo16ViewState extends State<UploadVideo16View> {
  File? _videoFile;
  bool _uploading = false;
  String _uploadStatus = '';
  // bool _canStartImageConvertion = false;
  String? _videoId;

  Future<void> _pickVideo() async {
    log('pick video');
    try {
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.video,
      //   // allowMultiple: false,
      // );

      final picker = ImagePicker();
      final result = await picker.pickVideo(source: ImageSource.gallery);

      if (result != null) {
        setState(() {
          _videoFile = File(result.path);
        });
      }
    } catch (e) {
      log('Error picking video: $e');
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) {
      setState(() {
        _uploadStatus = 'Please select a video first.';
      });
      return;
    }

    setState(() {
      _uploading = true;
      _uploadStatus = 'Uploading...';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/video/upload'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          _videoFile!.path,
          contentType: MediaType('video', 'mp4'),
        ),
      );

      final response = await request.send();
      final httpResponse = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        try {
          final jsonResponse =
              jsonDecode(httpResponse.body) as Map<String, dynamic>;
          final uploadResponse = UploadResponse.fromJson(jsonResponse);

          setState(() {
            _uploadStatus =
                // ignore: lines_longer_than_80_chars
                'Upload successful! Video ID: ${uploadResponse.videoId}, Message: ${uploadResponse.message}';
            _uploading = false;
            _videoId = uploadResponse.videoId;
          });
          await _startVideoConversion();
          log(
            // ignore: lines_longer_than_80_chars
            'Uploaded! Video ID: ${uploadResponse.videoId}, Message: ${uploadResponse.message}',
          );
        } catch (e) {
          setState(() {
            _uploadStatus = 'Failed to parse JSON response: $e';
            _uploading = false;
          });
          log('JSON parsing error: $e');
        }
      } else {
        setState(() {
          _uploadStatus = 'Upload failed. Status code: ${response.statusCode}';
          _uploading = false;
        });
        log('Upload failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed. Error: $e';
        _uploading = false;
      });
      log('Error uploading video: $e');
    }
  }

  Future<void> _startVideoConversion() async {
    try {
      final response = await http
          .post(Uri.parse('http://localhost:3000/video/convert/$_videoId'));

      if (response.statusCode == 200) {
        log('converted successfully ${response.body}');
      } else {
        // ignore: lines_longer_than_80_chars
        log('Error converting video: ${response.statusCode} => ${response.body}');
      }
    } catch (e) {
      log('Error converting video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Upload')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_videoFile != null) Text('Selected Video: ${_videoFile!.path}'),
            ElevatedButton(
              onPressed: _uploading ? null : _pickVideo,
              child: const Text('Pick Video'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploading ? null : _uploadVideo,
              child: const Text('Upload Video'),
            ),
            const SizedBox(height: 20),
            Text(_uploadStatus),
            if (_uploading) const CircularProgressIndicator(),
            ElevatedButton(
              onPressed: () =>
                  context.router.push(VideoStream16Route(videoId: _videoId)),
              child: const Text('Play Video'),
            ),
          ],
        ),
      ),
    );
  }
}
