import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(VortexApp());

class VortexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00050A), // Tu azul oscuro
      ),
      home: VortexSplash(),
    );
  }
}

class VortexSplash extends StatefulWidget {
  @override
  _VortexSplashState createState() => _VortexSplashState();
}

class _VortexSplashState extends State<VortexSplash> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/vortex.mp4")
      ..initialize().then((_) {
        setState(() {}); // Esto quita el círculo de carga
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        // Cuando el video termina, pasa al Login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
            : Container(), // Pantalla negra limpia mientras carga el video
      ),
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 45, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              SizedBox(height: 50),
              TextField(decoration: InputDecoration(labelText: "Correo", border: OutlineInputBorder())),
              SizedBox(height: 20),
              TextField(obscureText: true, decoration: InputDecoration(labelText: "Contraseña", border: OutlineInputBorder())),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                onPressed: () {
                  // Aquí conectaremos el código de verificación por mail
                },
                child: Text("INICIAR SESIÓN"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
