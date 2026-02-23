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
      ),
      home: const VortexSplash(),
    );
  }
}

// --- TRANSICIÓN INICIAL (VIDEO) ---
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
      ..initialize().then((_) { setState(() {}); _controller.play(); });
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainAuthScreen()));
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

// --- NÚCLEO DE AUTENTICACIÓN (LOGIN/REGISTRO) ---
class MainAuthScreen extends StatefulWidget {
  const MainAuthScreen({super.key});
  @override
  State<MainAuthScreen> createState() => _MainAuthScreenState();
}

class _MainAuthScreenState extends State<MainAuthScreen> {
  bool isDeviceRegistered = false;
  bool showRegisterView = false;
  String hardwareID = "DETECTANDO...";
  
  // Variables de Registro
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isCodeSent = false;
  bool _canClickResend = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceConfig();
  }

  Future<void> _loadDeviceConfig() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceInfo = DeviceInfoPlugin();
    String id = "";
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfo.androidInfo;
        id = build.id; 
      } else { id = "VX-PC-TEST-MODE"; }
    } catch (e) { id = "ERROR-ID"; }

    setState(() {
      hardwareID = "ID: ${id.toUpperCase()}";
      isDeviceRegistered = prefs.getBool('vortex_master_reg') ?? false;
    });
  }

  void _startCountdown() {
    setState(() { _isCodeSent = true; _canClickResend = false; _secondsRemaining = 60; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining == 0) { setState(() { t.cancel(); _canClickResend = true; }); }
      else { setState(() => _secondsRemaining--); }
    });
    _showToast("Código enviado al correo");
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.cyanAccent.withOpacity(0.5)));
  }

  // --- INTERFAZ PREMIUM (WIDGETS) ---
  Widget _vortexInput({required String label, bool obscure = false, TextEditingController? controller}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.lexend(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent, width: 2)),
        ),
      ),
    );
  }

  Widget _vortexButton({required String text, required VoidCallback? onTap, Color color = Colors.cyanAccent}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [if (onTap != null) BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, spreadRadius: 1)],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 65),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(text, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
      ),
    );
  }

  // --- VENTANA DE CONTRASEÑA (MODAL PREMIUM) ---
  void _openPasswordFinalization() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF001218),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, color: Colors.cyanAccent, size: 50),
                const SizedBox(height: 20),
                Text("CREAR CONTRASEÑA", style: GoogleFonts.orbitron(fontSize: 20, color: Colors.cyanAccent)),
                const SizedBox(height: 30),
                _vortexInput(label: "Nueva Contraseña", obscure: true),
                _vortexInput(label: "Confirmar Contraseña", obscure: true),
                const SizedBox(height: 40),
                _vortexButton(text: "FINALIZAR", onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('vortex_master_reg', true);
                  Navigator.pop(context);
                  _completeRegistration();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeRegistration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF00050A),
        title: const Text("VORTEX ACTIVADO"),
        content: Text("Equipo vinculado con éxito.\nTu ID de acceso es: ${hardwareID.replaceAll("ID: ", "")}"),
        actions: [
          TextButton(onPressed: () { 
            Navigator.pop(context); 
            setState(() { isDeviceRegistered = true; showRegisterView = false; });
          }, child: const Text("EMPEZAR"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shortcuts( // SOPORTE PARA CONTROL REMOTO TV
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(50),
            child: Column(
              children: [
                Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 65, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 12)),
                Text(hardwareID, style: GoogleFonts.lexend(color: Colors.white24, fontSize: 14)),
                const SizedBox(height: 60),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: showRegisterView ? _buildRegisterUI() : _buildLoginUI(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginUI() {
    return Column(
      children: [
        Text("INICIAR SESIÓN", style: GoogleFonts.lexend(fontSize: 20, letterSpacing: 2)),
        const SizedBox(height: 35),
        _vortexInput(label: "ID de Usuario"),
        _vortexInput(label: "Contraseña", obscure: true),
        const SizedBox(height: 40),
        _vortexButton(text: "INGRESAR", onTap: () { /* ACCESO AL MENU */ }),
        if (!isDeviceRegistered)
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: TextButton(
              onPressed: () => setState(() => showRegisterView = true),
              child: const Text("REGISTRAR ESTE DISPOSITIVO", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterUI() {
    return Column(
      children: [
        Text("REGISTRO DE EQUIPO", style: GoogleFonts.lexend(fontSize: 20, letterSpacing: 2)),
        const SizedBox(height: 30),
        _vortexInput(label: "Correo Electrónico"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _vortexInput(label: "Código de Seguridad")),
            const SizedBox(width: 15),
            SizedBox(
              width: 130,
              child: _vortexButton(
                text: !_isCodeSent ? "ENVIAR" : (_canClickResend ? "RE-ENVIAR" : "$_secondsRemaining s"),
                onTap: (!_isCodeSent || _canClickResend) ? _startCountdown : null,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        _vortexButton(text: "COMPROBAR CÓDIGO", onTap: _isCodeSent ? _openPasswordFinalization : null),
        TextButton(onPressed: () => setState(() => showRegisterView = false), child: const Text("Volver al inicio")),
      ],
    );
  }
}
