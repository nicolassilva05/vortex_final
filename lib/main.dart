import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
        focusColor: Colors.cyanAccent.withOpacity(0.3),
      ),
      home: const VortexSplash(),
    );
  }
}

// --- SPLASH SCREEN ---
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

// --- PANTALLA PRINCIPAL ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRegistered = false;
  bool showRegister = false;
  String deviceID = "Cargando...";

  // Lógica de Registro
  int _start = 60;
  Timer? _timer;
  bool _codeSent = false;
  bool _canResend = false;

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
      } else { id = "VORTEX-PC-TEST"; }
    } catch (e) { id = "ID-DESCONOCIDO"; }
    setState(() => deviceID = "ID: ${id.toUpperCase()}");
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { isRegistered = prefs.getBool('vortex_reg_complete') ?? false; });
  }

  void startTimer() {
    setState(() {
      _codeSent = true;
      _canResend = false;
      _start = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_start == 0) {
        setState(() {
          t.cancel();
          _canResend = true;
        });
      } else {
        setState(() => _start--);
      }
    });
    
    // Simulación de cartel de envío
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Código enviado al correo elegido"), backgroundColor: Colors.cyan),
    );
  }

  // Ventana Emergente de Contraseña (Modal Opaco)
  void _showPasswordModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.8), // Fondo opaco
        child: AlertDialog(
          backgroundColor: const Color(0xFF001015),
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(20)),
          title: const Text("ASIGNAR CONTRASEÑA", textAlign: TextAlign.center, style: TextStyle(color: Colors.cyanAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(label: "Nueva Contraseña", obscure: true),
              const SizedBox(height: 15),
              _input(label: "Repetir Contraseña", obscure: true),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('vortex_reg_complete', true);
                Navigator.pop(context); // Cerrar modal contraseña
                _showSuccessDialog();
              },
              child: const Text("CONTINUAR"),
            )
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¡ÉXITO!"),
        content: Text("Cuenta creada exitosamente.\nTu ID asignado es: ${deviceID.replaceAll("ID: ", "")}"),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
            setState(() { isRegistered = true; showRegister = false; });
          }, child: const Text("OK"))
        ],
      ),
    );
  }

  Widget _input({required String label, bool obscure = false, Widget? suffix}) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        labelStyle: const TextStyle(color: Colors.white60),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent, width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shortcuts(
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
                  constraints: const BoxConstraints(maxWidth: 500),
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
        _input(label: "Usuario (ID)"),
        const SizedBox(height: 15),
        _input(label: "Contraseña", obscure: true),
        const SizedBox(height: 35),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60)),
          onPressed: () {},
          child: const Text("INGRESAR", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (!isRegistered)
          TextButton(onPressed: () => setState(() => showRegister = true), child: const Text("¿Nuevo? Regístrate aquí", style: TextStyle(color: Colors.cyanAccent))),
      ],
    );
  }

  Widget buildRegister() {
    return Column(
      children: [
        const Text("REGISTRO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _input(label: "Correo electrónico (Gmail/Hotmail)"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _input(label: "Código de Verificación")),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                onPressed: (!_codeSent || _canResend) ? startTimer : null,
                child: Text(!_codeSent ? "ENVIAR" : (_canResend ? "RE-ENVIAR" : "$_start s")),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60)),
          onPressed: _codeSent ? _showPasswordModal : null,
          child: const Text("COMPROBAR"),
        ),
      ],
    );
  }
}
