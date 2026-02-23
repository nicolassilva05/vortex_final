import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VortexApp());
}

class VortexApp extends StatelessWidget {
  const VortexApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00050A),
      ),
      home: const VortexSplash(),
    );
  }
}

class VortexSplash extends StatefulWidget {
  const VortexSplash({super.key});
  @override
  State<VortexSplash> createState() => _VortexSplashState();
}

class _VortexSplashState extends State<VortexSplash> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/vortex.mp4")
      ..initialize().then((_) {
        setState(() {}); 
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
            : const CircularProgressIndicator(color: Colors.cyanAccent),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRegistered = false;
  bool showRegister = false;
  int _start = 60;
  Timer? _timer;
  String deviceID = "Cargando ID...";

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _getDeviceID();
  }

  // Función para obtener el ID único del dispositivo
  Future<void> _getDeviceID() async {
    var deviceInfo = DeviceInfoPlugin();
    String id = "";
    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      id = build.id; 
    } else if (Platform.isIOS) {
      var data = await deviceInfo.iosInfo;
      id = data.identifierForVendor ?? "Desconocido";
    }
    setState(() => deviceID = "ID: ${id.toUpperCase()}");
  }

  // Función para ver si ya se registró antes
  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isRegistered = prefs.getBool('isRegistered') ?? false;
    });
  }

  void startTimer() {
    _timer?.cancel();
    setState(() => _start = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) { setState(() => timer.cancel()); } 
      else { setState(() => _start--); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 50, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 5)),
              Text(deviceID, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 40),
              
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: showRegister ? buildRegister() : buildLogin(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogin() {
    return Column(
      children: [
        const Text("INICIAR SESIÓN", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 25),
        const TextField(decoration: InputDecoration(labelText: "Usuario (ID)", border: OutlineInputBorder())),
        const SizedBox(height: 15),
        const TextField(obscureText: true, decoration: InputDecoration(labelText: "Contraseña", border: OutlineInputBorder())),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
          onPressed: () { /* Lógica de entrada */ },
          child: const Text("INGRESAR", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        if (!isRegistered)
          TextButton(
            onPressed: () { setState(() => showRegister = true); startTimer(); },
            child: const Text("¿Nuevo dispositivo? Regístrate aquí", style: TextStyle(color: Colors.cyanAccent)),
          ),
      ],
    );
  }

  Widget buildRegister() {
    return Column(
      children: [
        const Text("REGISTRO DE EQUIPO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 25),
        const TextField(decoration: InputDecoration(labelText: "Correo electrónico", border: OutlineInputBorder())),
        const SizedBox(height: 15),
        const TextField(decoration: InputDecoration(labelText: "Código de Verificación", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        _start > 0 
          ? Text("Reenviar código en $_start s", style: const TextStyle(color: Colors.grey))
          : TextButton(onPressed: startTimer, child: const Text("REENVIAR CÓDIGO", style: TextStyle(color: Colors.cyanAccent))),
        const SizedBox(height: 15),
        const TextField(obscureText: true, decoration: InputDecoration(labelText: "Asignar Contraseña", border: OutlineInputBorder())),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isRegistered', true);
            showDialog(context: context, builder: (c) => const AlertDialog(title: Text("VORTEX"), content: Text("¡Dispositivo registrado con éxito!")));
            setState(() { isRegistered = true; showRegister = false; });
          },
          child: const Text("FINALIZAR Y VINCULAR"),
        ),
      ],
    );
  }
}
