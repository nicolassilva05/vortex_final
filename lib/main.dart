import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
        scaffoldBackgroundColor: const Color(0xFF00050A), // Tu azul oscuro
        focusColor: Colors.cyanAccent.withOpacity(0.3), // Color de selección en TV
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
  String deviceID = "Obteniendo ID...";

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _getDeviceID();
  }

  Future<void> _getDeviceID() async {
    var deviceInfo = DeviceInfoPlugin();
    String id = "";
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfo.androidInfo;
        id = build.id; 
      } else { id = "GENERIC-DEV-ID"; }
    } catch (e) { id = "UNKNOWN-ID"; }
    setState(() => deviceID = "ID: ${id.toUpperCase()}");
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { isRegistered = prefs.getBool('isRegistered') ?? false; });
  }

  void startTimer() {
    _timer?.cancel();
    setState(() => _start = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) { setState(() => timer.cancel()); } 
      else { setState(() => _start--); }
    });
  }

  Widget _buildTextField({required String label, bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent, width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shortcuts( // Esto habilita el control remoto de Android TV
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 55, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 8)),
                Text(deviceID, style: const TextStyle(color: Colors.white38, fontSize: 14)),
                const SizedBox(height: 40),
                Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: showRegister ? buildRegister() : buildLogin(),
                ),
              ],
            ),
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
        _buildTextField(label: "Usuario (ID)"),
        const SizedBox(height: 15),
        _buildTextField(label: "Contraseña", obscure: true),
        const SizedBox(height: 35),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: () { /* Acción de entrar */ },
          child: const Text("INGRESAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        if (!isRegistered) // Solo muestra registro si no hay cuenta vinculada
          TextButton(
            onPressed: () { setState(() => showRegister = true); startTimer(); },
            child: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("¿Dispositivo nuevo? Regístrate aquí", style: TextStyle(color: Colors.cyanAccent)),
            ),
          ),
      ],
    );
  }

  Widget buildRegister() {
    return Column(
      children: [
        const Text("REGISTRO DE EQUIPO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 25),
        _buildTextField(label: "Correo electrónico"),
        const SizedBox(height: 15),
        _buildTextField(label: "Código de Verificación"),
        const SizedBox(height: 10),
        _start > 0 
          ? Text("Reenviar código en $_start s", style: const TextStyle(color: Colors.grey))
          : TextButton(onPressed: startTimer, child: const Text("REENVIAR CÓDIGO", style: TextStyle(color: Colors.cyanAccent))),
        const SizedBox(height: 15),
        _buildTextField(label: "Asignar Contraseña", obscure: true),
        const SizedBox(height: 35),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isRegistered', true);
            setState(() { isRegistered = true; showRegister = false; });
          },
          child: const Text("VINCULAR DISPOSITIVO", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
