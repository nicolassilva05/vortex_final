import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';

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

// --- 1. VIDEO SPLASH INITIAL ---
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
    return Scaffold(backgroundColor: Colors.black, body: Center(child: _controller.value.isInitialized ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)) : const CircularProgressIndicator(color: Colors.cyanAccent)));
  }
}

// --- 2. PANTALLA PRINCIPAL (AUTH, REGISTRO Y BUSCADOR) ---
class MainAuthScreen extends StatefulWidget {
  const MainAuthScreen({super.key});
  @override
  State<MainAuthScreen> createState() => _MainAuthScreenState();
}

class _MainAuthScreenState extends State<MainAuthScreen> {
  // Estados de sesión y hardware
  bool isDeviceRegistered = false;
  bool showRegisterView = false;
  bool isLoggedIn = false; // Cambia a true tras login exitoso
  String hardwareID = "DETECTANDO...";
  String localTime = "";

  // Lógica de Registro (Contador)
  int _seconds = 60;
  Timer? _timer;
  bool _codeSent = false;
  bool _canResend = false;

  // Lógica Buscador Predictivo (Estilo Netflix)
  TextEditingController _searchController = TextEditingController();
  List<String> catalogo = ["AVENGERS", "AVATAR", "ANIME: NARUTO", "ANIME: ONE PIECE", "BATMAN", "BREAKING BAD", "DRAGON BALL Z", "EL REY LEON", "FROZEN", "STRANGER THINGS"];
  List<String> resultados = [];

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _updateClock();
    Timer.periodic(const Duration(seconds: 30), (t) => _updateClock());
  }

  void _updateClock() { setState(() { localTime = DateFormat('HH:mm').format(DateTime.now()); }); }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceInfo = DeviceInfoPlugin();
    String id = "";
    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      id = build.id;
    } else { id = "VORTEX-PC-MODE"; }
    setState(() {
      hardwareID = id.toUpperCase();
      isDeviceRegistered = prefs.getBool('reg_$id') ?? false;
    });
  }

  void _startTimer() {
    setState(() { _codeSent = true; _canResend = false; _seconds = 60; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) { setState(() { t.cancel(); _canResend = true; }); }
      else { setState(() => _seconds--); }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Código enviado al correo")));
  }

  // --- WIDGETS DE INTERFAZ PREMIUM ---
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
          fillColor: Colors.white.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent, width: 2)),
        ),
      ),
    );
  }

  Widget _vortexButton({required String text, required VoidCallback? onTap, Color color = Colors.cyanAccent}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), boxShadow: [if (onTap != null) BoxShadow(color: color.withOpacity(0.2), blurRadius: 15)]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: onTap,
        child: Text(text, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }

  // --- MODAL DE CONTRASEÑA (OPACIDAD 95%) ---
  void _openPasswordModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 450, padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: const Color(0xFF001218), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.cyanAccent.withOpacity(0.5))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("ASIGNAR CONTRASEÑA", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 20)),
                const SizedBox(height: 30),
                _vortexInput(label: "Contraseña Nueva", obscure: true),
                _vortexInput(label: "Repetir Contraseña", obscure: true),
                const SizedBox(height: 40),
                _vortexButton(text: "FINALIZAR", onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('reg_$hardwareID', true);
                  Navigator.pop(context);
                  setState(() { isDeviceRegistered = true; showRegisterView = false; });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) return _buildMainInterface();
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 40, right: 40, child: Text(localTime, style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 22))),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 60, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 10)),
                  Text("ID: $hardwareID", style: const TextStyle(color: Colors.white24)),
                  const SizedBox(height: 50),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                    child: showRegisterView ? _buildRegisterUI() : _buildLoginUI(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginUI() {
    return Column(
      children: [
        Text("INICIAR SESIÓN", style: GoogleFonts.lexend(fontSize: 18)),
        const SizedBox(height: 30),
        _vortexInput(label: "ID de Usuario"),
        _vortexInput(label: "Contraseña", obscure: true),
        const SizedBox(height: 35),
        _vortexButton(text: "INGRESAR", onTap: () => setState(() => isLoggedIn = true)),
        if (!isDeviceRegistered)
          TextButton(onPressed: () => setState(() => showRegisterView = true), child: const Text("Registrar este equipo", style: TextStyle(color: Colors.cyanAccent))),
      ],
    );
  }

  Widget _buildRegisterUI() {
    return Column(
      children: [
        Text("VINCULACIÓN", style: GoogleFonts.lexend(fontSize: 18)),
        const SizedBox(height: 25),
        _vortexInput(label: "Correo Electrónico"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _vortexInput(label: "Código")),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              child: _vortexButton(
                text: !_codeSent ? "ENVIAR" : (_canResend ? "RE-ENVIAR" : "$_seconds"),
                onTap: (!_codeSent || _canResend) ? _startTimer : null,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 35),
        _vortexButton(text: "COMPROBAR", onTap: _codeSent ? _openPasswordModal : null),
        TextButton(onPressed: () => setState(() => showRegisterView = false), child: const Text("Volver"))
      ],
    );
  }

  // --- 3. INTERFAZ FINAL: BUSCADOR NETFLIX STYLE ---
  Widget _buildMainInterface() {
    return Scaffold(
      body: Row(
        children: [
          // TECLADO IZQUIERDA (TV)
          Container(
            width: 320, color: Colors.black54, padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text("BUSCAR", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
                const SizedBox(height: 20),
                _vortexInput(label: "Escribiendo...", controller: _searchController),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 5, crossAxisSpacing: 5),
                    itemCount: 36,
                    itemBuilder: (context, i) {
                      String char = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"[i];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _searchController.text += char;
                            resultados = catalogo.where((e) => e.contains(_searchController.text.toUpperCase())).toList();
                          });
                        },
                        child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)), child: Center(child: Text(char))),
                      );
                    },
                  ),
                ),
                _vortexButton(text: "BORRAR", color: Colors.redAccent, onTap: () {
                  setState(() {
                    if (_searchController.text.isNotEmpty) {
                      _searchController.text = _searchController.text.substring(0, _searchController.text.length - 1);
                      resultados = catalogo.where((e) => e.contains(_searchController.text.toUpperCase())).toList();
                    }
                  });
                }),
              ],
            ),
          ),
          // RESULTADOS DERECHA (PREDICTIVOS)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("RESULTADOS", style: GoogleFonts.orbitron(fontSize: 22)),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.7, crossAxisSpacing: 20, mainAxisSpacing: 20),
                      itemCount: resultados.length,
                      itemBuilder: (context, i) => Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.cyanAccent.withOpacity(0.2))),
                        child: Center(child: Text(resultados[i], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
