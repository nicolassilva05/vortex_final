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
  // Permitimos rotación pero priorizamos la experiencia inmersiva
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  runApp(const VortexApp());
}

class VortexApp extends StatelessWidget {
  const VortexApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vortex Ultimate',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00050A),
        primaryColor: Colors.cyanAccent,
      ),
      home: const VortexSplash(),
    );
  }
}

// --- 1. VIDEO SPLASH PROFESIONAL ---
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MasterScreen()));
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
          ? SizedBox.expand(child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: _controller.value.size.width, height: _controller.value.size.height, child: VideoPlayer(_controller))))
          : const CircularProgressIndicator(color: Colors.cyanAccent),
      ),
    );
  }
}

// --- 2. NÚCLEO DEL SISTEMA VORTEX ---
class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});
  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  // --- ESTADOS ---
  bool isRegistered = false;
  bool showRegister = false;
  bool isLoggedIn = false;
  String deviceID = "DETECTOR...";
  String localTime = "";
  
  // Datos de Usuario
  String userMail = "admin@vortex.com";
  String userPass = "123456";

  // Buscador y Catálogo
  TextEditingController _searchCtrl = TextEditingController();
  List<String> catalogo = ["AVENGERS", "AVATAR", "NARUTO", "ONE PIECE", "BATMAN", "DRAGON BALL", "STRANGER THINGS", "FROZEN", "EL REY LEON", "ANIME: BLEACH"];
  List<String> resultados = [];

  // Lógica de Registro
  int _seconds = 60;
  Timer? _timer;
  bool _codeSent = false;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _initDevice();
    _startClock();
  }

  void _startClock() {
    _updateTime();
    Timer.periodic(const Duration(seconds: 30), (t) => _updateTime());
  }
  void _updateTime() { setState(() { localTime = DateFormat('HH:mm').format(DateTime.now()); }); }

  Future<void> _initDevice() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceInfo = DeviceInfoPlugin();
    String id = "";
    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      id = build.id;
    } else { id = "VORTEX-TV-STATION"; }
    setState(() { deviceID = id.toUpperCase(); isRegistered = prefs.getBool('reg_$id') ?? false; });
  }

  void _startTimer() {
    setState(() { _codeSent = true; _canResend = false; _seconds = 60; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) { setState(() { t.cancel(); _canResend = true; }); }
      else { setState(() => _seconds--); }
    });
  }

  // --- COMPONENTES RESPONSIVOS ---
  double res(BuildContext context, double original) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1000) return original; // TV
    return original * 0.8; // Mobile
  }

  // --- MODAL DE PERFIL (CORREGIDO: ID BLOQUEADO) ---
  void _openProfile() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, a1, a2) => Center(
        child: SingleChildScrollView(
          child: Material(color: Colors.transparent, child: Container(
            width: res(context, 500),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: const Color(0xFF00050A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent.withOpacity(0.2))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(radius: 40, backgroundColor: Colors.cyanAccent, child: const Icon(Icons.person, color: Colors.black, size: 40)),
              const SizedBox(height: 20),
              Text("CUENTA VORTEX", style: GoogleFonts.orbitron(fontSize: 18, color: Colors.cyanAccent)),
              const SizedBox(height: 30),
              _profileField("ID DISPOSITIVO", deviceID, false),
              _profileField("CORREO", userMail, true, onEdit: () => _editProfile("Correo")),
              _profileField("CONTRASEÑA", "********", true, onEdit: _securityPassCheck),
              const SizedBox(height: 40),
              _vortexButton(text: "CERRAR SESIÓN", color: Colors.redAccent, onTap: () => setState(() => isLoggedIn = false)),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("VOLVER")),
            ]),
          )),
        ),
      ),
    );
  }

  Widget _profileField(String label, String val, bool editable, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          Text(val, style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.bold)),
        ])),
        if (editable) IconButton(icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20), onPressed: onEdit)
        else const Icon(Icons.lock, color: Colors.white12, size: 20),
      ]),
    );
  }

  void _securityPassCheck() {
    TextEditingController _c = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Seguridad"),
      content: TextField(controller: _c, obscureText: true, decoration: const InputDecoration(hintText: "Contraseña Actual")),
      actions: [ TextButton(onPressed: () { if(_c.text == userPass) { Navigator.pop(c); _showChangePassModal(true); } }, child: const Text("VALIDAR")) ],
    ));
  }

  void _editProfile(String campo) {
    TextEditingController _c = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Editar $campo"),
      content: TextField(controller: _c),
      actions: [ TextButton(onPressed: () { setState(() => userMail = _c.text); Navigator.pop(c); }, child: const Text("GUARDAR")) ],
    ));
  }

  // --- SISTEMA DE RECUPERACIÓN ---
  void _openRecovery() {
    showGeneralDialog(context: context, barrierColor: Colors.black.withOpacity(0.95), pageBuilder: (context, a1, a2) => Center(
      child: Material(color: Colors.transparent, child: Container(width: 400, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: const Color(0xFF001015), borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("RECUPERAR", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
          _vortexInput(label: "Email Asignado"),
          const SizedBox(height: 20),
          _vortexButton(text: "ENVIAR CÓDIGO", onTap: () { Navigator.pop(context); _openCodeVerify(); }),
        ]),
      )),
    ));
  }

  void _openCodeVerify() {
    showGeneralDialog(context: context, barrierColor: Colors.black.withOpacity(0.95), pageBuilder: (context, a1, a2) => Center(
      child: Material(color: Colors.transparent, child: Container(width: 400, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: const Color(0xFF001015), borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("INGRESA EL CÓDIGO DEL MAIL"),
          _vortexInput(label: "6 Dígitos"),
          const SizedBox(height: 20),
          _vortexButton(text: "CONTINUAR", onTap: () { Navigator.pop(context); _showChangePassModal(true); }),
        ]),
      )),
    ));
  }

  void _showChangePassModal(bool isReset) {
    TextEditingController _p1 = TextEditingController();
    showGeneralDialog(context: context, barrierColor: Colors.black.withOpacity(0.95), pageBuilder: (context, a1, a2) => Center(
      child: Material(color: Colors.transparent, child: Container(width: 400, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: const Color(0xFF001218), borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("NUEVA CLAVE", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
          _vortexInput(label: "Nueva Contraseña", obscure: true, controller: _p1),
          _vortexInput(label: "Repetir Contraseña", obscure: true),
          const SizedBox(height: 30),
          _vortexButton(text: "CONFIRMAR CAMBIO", onTap: () {
            setState(() => userPass = _p1.text);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cambio Exitoso")));
          }),
        ]),
      )),
    ));
  }

  // --- INTERFAZ RESPONSIVA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: isLoggedIn ? _buildHome() : _buildAuth()),
    );
  }

  Widget _buildAuth() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(children: [
          Text("VORTEX", style: GoogleFonts.orbitron(fontSize: res(context, 60), color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 8)),
          const SizedBox(height: 40),
          Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
            child: showRegister ? _buildRegisterUI() : _buildLoginUI(),
          ),
        ]),
      ),
    );
  }

  Widget _buildLoginUI() {
    return Column(children: [
      _vortexInput(label: "ID / Correo"),
      _vortexInput(label: "Contraseña", obscure: true),
      const SizedBox(height: 20),
      _vortexButton(text: "INGRESAR", onTap: () => setState(() => isLoggedIn = true)),
      TextButton(onPressed: _openRecovery, child: const Text("¿Olvidaste tu contraseña?")),
      if(!isRegistered) TextButton(onPressed: () => setState(() => showRegister = true), child: const Text("Registrar Equipo", style: TextStyle(color: Colors.cyanAccent))),
    ]);
  }

  Widget _buildRegisterUI() {
    return Column(children: [
      _vortexInput(label: "Correo Electrónico"),
      Row(children: [
        Expanded(child: _vortexInput(label: "Código")),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: _vortexButton(text: !_codeSent ? "ENVIAR" : (_canResend ? "RE-ENVIAR" : "$_seconds"), onTap: (!_codeSent || _canResend) ? _startTimer : null, color: Colors.white)),
      ]),
      const SizedBox(height: 30),
      _vortexButton(text: "COMPROBAR", onTap: _codeSent ? () => _showChangePassModal(false) : null),
      TextButton(onPressed: () => setState(() => showRegister = false), child: const Text("Volver al Login")),
    ]);
  }

  Widget _buildHome() {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Text("VORTEX", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 22)),
          const Spacer(),
          Text(localTime, style: GoogleFonts.orbitron(color: Colors.white24, fontSize: 18)),
          const SizedBox(width: 20),
          IconButton(icon: const Icon(Icons.person_pin, size: 30, color: Colors.cyanAccent), onPressed: _openProfile),
        ]),
      ),
      Expanded(
        child: Flex(
          direction: isTV ? Axis.horizontal : Axis.vertical,
          children: [
            Container(
              width: isTV ? 320 : double.infinity,
              height: isTV ? double.infinity : 220,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                _vortexInput(label: "Buscar Película...", controller: _searchCtrl),
                if(isTV) Expanded(child: _buildTVKeyboard()),
              ]),
            ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    ]);
  }

  Widget _buildTVKeyboard() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
      itemCount: 36,
      itemBuilder: (c, i) {
        String k = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"[i];
        return InkWell(
          onTap: () {
            _searchCtrl.text += k;
            setState(() { resultados = catalogo.where((e) => e.contains(_searchCtrl.text.toUpperCase())).toList(); });
          },
          child: Center(child: Text(k, style: const TextStyle(fontSize: 12))),
        );
      },
    );
  }

  Widget _buildResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
        childAspectRatio: 0.7, crossAxisSpacing: 15, mainAxisSpacing: 15,
      ),
      itemCount: resultados.length,
      itemBuilder: (c, i) => Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.cyanAccent.withOpacity(0.1))),
        child: Center(child: Text(resultados[i], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      ),
    );
  }

  // --- WIDGETS DE ESTILO ---
  Widget _vortexInput({required String label, bool obscure = false, TextEditingController? controller}) {
    return Container(margin: const EdgeInsets.symmetric(vertical: 8), child: TextField(controller: controller, obscureText: obscure, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))));
  }

  Widget _vortexButton({required String text, required VoidCallback? onTap, Color color = Colors.cyanAccent}) {
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: onTap, child: Text(text, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12)));
  }
}
