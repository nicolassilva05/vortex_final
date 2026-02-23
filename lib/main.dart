import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MaterialApp(home: VortexApp(), debugShowCheckedModeBanner: false));

class VortexApp extends StatefulWidget {
  @override
  _VortexAppState createState() => _VortexAppState();
}

class _VortexAppState extends State<VortexApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Video de prueba directo para asegurar que la app compile bien
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
            : CircularProgressIndicator(color: Colors.blueAccent),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _controller.value.isPlaying ? _controller.pause() : _controller.play()),
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
