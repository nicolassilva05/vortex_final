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

// --- 1. VIDEO DE ENTRADA ---
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VortexMasterScreen()));
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

// --- 2. PANTALLA MAESTRA (TODO EL SISTEMA UNIFICADO) ---
class VortexMasterScreen extends StatefulWidget {
  const VortexMasterScreen({super.key});
  @override
  State<VortexMasterScreen> createState() => _VortexMasterScreenState();
}

class _VortexMasterScreenState extends State<VortexMasterScreen> {
  // Estados de Usuario y Dispositivo
  bool isDeviceRegistered = false;
  bool showRegisterView = false;
  bool isLoggedIn = false;
  String hardwareID = "DETECTANDO...";
  String localTime = "";
  String userEmail = "usuario@vortex.com";
  String userPass = "123456";

  // Buscador Predictivo
  TextEditingController _searchCtrl = TextEditingController();
  List<String> catalogo = ["AVENGERS", "AVATAR", "NARUTO", "ONE PIECE", "BATMAN", "DRAGON BALL", "EL REY LEON", "FROZEN", "STRANGER THINGS", "ANIME: BLEACH"];
  List<String> resultados = [];

  // Lógica de Registro (Contador)
  int _seconds = 60;
  Timer? _timer;
  bool _codeSent = false;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _loadHardwareInfo();
    _startClock();
  }

  void _startClock() {
    _updateTime();
    Timer.periodic(const Duration(seconds: 30), (t) => _updateTime());
  }

  void _updateTime() {
    setState(() { localTime = DateFormat('HH:mm').format(DateTime.now()); });
  }

  Future<void> _loadHardwareInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceInfo = DeviceInfoPlugin();
    String id = "";
    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      id = build.id;
    } else { id = "VORTEX-TV-STATION-77"; }
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
  }

  // --- MODAL: SEGURIDAD (95% OPACIDAD) ---
  void _showPasswordSetupModal({required bool isResetFlow}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, a1, a2) => Center(
        child: Material(color: Colors.transparent, child: Container(
          width: 450, padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: const Color(0xFF001218), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.cyanAccent)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(isResetFlow ? "NUEVA CONTRASEÑA" : "ASIGNAR CONTRASEÑA", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18)),
            const SizedBox(height: 30),
            _vortexInput(label: "Contraseña", obscure: true),
            _vortexInput(label: "Confirmar Contraseña", obscure: true),
            const SizedBox(height: 40),
            _vortexButton(text: "FINALIZAR", onTap: () async {
              if (!isResetFlow) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('reg_$hardwareID', true);
                setState(() => isDeviceRegistered = true);
              }
              Navigator.pop(context);
              if (isResetFlow) _showToast("Contraseña actualizada correctamente");
            }),
          ]),
        )),
      ),
    );
  }

  // --- FLUJO RECUPERAR CONTRASEÑA ---
  void _forgotPasswordFlow() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, a1, a2) => Center(
        child: Material(color: Colors.transparent, child: Container(
          width: 450, padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: const Color(0xFF001015), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("RECUPERACIÓN", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
            const SizedBox(height: 20),
            _vortexInput(label: "Tu correo asignado"),
            const SizedBox(height: 20),
            _vortexButton(text: "ENVIAR CÓDIGO", onTap: () {
              Navigator.pop(context);
              _verifyCodeAndReset();
            }),
          ]),
        )),
      ),
    );
  }

  void _verifyCodeAndReset() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, a1, a2) => Center(
        child: Material(color: Colors.transparent, child: Container(
          width: 450, padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: const Color(0xFF001015), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("CÓDIGO ENVIADO AL MAIL"),
            const SizedBox(height: 20),
            _vortexInput(label: "Código de Verificación"),
            const SizedBox(height: 20),
            _vortexButton(text: "CONTINUAR", onTap: () {
              Navigator.pop(context);
              _showPasswordSetupModal(isResetFlow: true);
            }),
          ]),
        )),
      ),
    );
  }

  // --- INTERFAZ DE PERFIL (ID NO MODIFICABLE) ---
  void _showProfileModal() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      pageBuilder: (context, a1, a2) => Center(child: Material(color: Colors.transparent, child: Container(
        width: 550, padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: const Color(0xFF00050A), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.cyanAccent, child: Icon(Icons.person, size: 50, color: Colors.black)),
          const SizedBox(height: 30),
          _profileItem(label: "ID DISPOSITIVO (Único)", val: hardwareID, canEdit: false),
          _profileItem(label: "CORREO ASIGNADO", val: userEmail, canEdit: true, onEdit: () => _editProfileField("Correo")),
          _profileItem(label: "CONTRASEÑA", val: "********", canEdit: true, onEdit: _profileSecurityCheck),
          const SizedBox(height: 40),
          _vortexButton(text: "CERRAR SESIÓN", color: Colors.redAccent, onTap: () => setState(() => isLoggedIn = false)),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("VOLVER")),
        ]),
      ))),
    );
  }

  Widget _profileItem({required String label, required String val, required bool canEdit, VoidCallback? onEdit}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        Text(val, style: GoogleFonts.lexend(fontSize: 17, fontWeight: FontWeight.bold)),
      ]),
      const Spacer(),
      if (canEdit) TextButton(onPressed: onEdit, child: const Text("MODIFICAR", style: TextStyle(color: Colors.cyanAccent)))
      else const Icon(Icons.lock, size: 18, color: Colors.white10),
    ]));
  }

  void _profileSecurityCheck() {
    TextEditingController _c = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Validación de Seguridad"),
      content: TextField(controller: _c, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña Actual")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCELAR")),
        TextButton(onPressed: () {
          if (_c.text == userPass) { Navigator.pop(c); _showPasswordSetupModal(isResetFlow: true); }
        }, child: const Text("VALIDAR")),
      ],
    ));
  }

  void _editProfileField(String field) {
    TextEditingController _c = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Modificar $field"),
      content: TextField(controller: _c, decoration: InputDecoration(hintText: "Nuevo $field")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCELAR")),
        TextButton(onPressed: () {
          setState(() { if(field == "Correo") userEmail = _c.text; });
          Navigator.pop(c);
        }, child: const Text("GUARDAR")),
      ],
    ));
  }

  // --- LÓGICA DE INTERFAZ (AUTH Y HOME) ---
  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) return _buildHomeInterface();
    return _buildAuthInterface();
  }

  Widget _buildAuthInterface() {
    return Scaffold(
      body: Stack(children: [
        Positioned(top: 40, right: 40, child: Text(localTime, style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 22))),
        Center(child: SingleChildScrollView(padding: const EdgeInsets.all(40), child: Column(children: [
          Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 60, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 10)),
          const SizedBox(height: 50),
          Container(constraints: const BoxConstraints(maxWidth: 500), padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
            child: showRegisterView ? _buildRegisterUI() : _buildLoginUI(),
          ),
        ]))),
      ]),
    );
  }

  Widget _buildLoginUI() {
    return Column(children: [
      _vortexInput(label: "ID Usuario / Correo"),
      _vortexInput(label: "Contraseña", obscure: true),
      const SizedBox(height: 30),
      _vortexButton(text: "INGRESAR", onTap: () => setState(() => isLoggedIn = true)),
      TextButton(onPressed: _forgotPasswordFlow, child: const Text("¿Olvidaste tu contraseña?")),
      if (!isDeviceRegistered) TextButton(onPressed: () => setState(() => showRegisterView = true), child: const Text("Registrar este equipo", style: TextStyle(color: Colors.cyanAccent))),
    ]);
  }

  Widget _buildRegisterUI() {
    return Column(children: [
      _vortexInput(label: "Correo Electrónico"),
      const SizedBox(height: 15),
      Row(children: [
        Expanded(child: _vortexInput(label: "Código")),
        const SizedBox(width: 10),
        SizedBox(width: 110, child: _vortexButton(text: !_codeSent ? "ENVIAR" : (_canResend ? "REENVIAR" : "$_seconds"), 
        onTap: (!_codeSent || _canResend) ? _startTimer : null, color: Colors.white)),
      ]),
      const SizedBox(height: 40),
      _vortexButton(text: "COMPROBAR", onTap: _codeSent ? () => _showPasswordSetupModal(isResetFlow: false) : null),
      TextButton(onPressed: () => setState(() => showRegisterView = false), child: const Text("Volver"))
    ]);
  }

  Widget _buildHomeInterface() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, 
        title: Text("VORTEX", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
        actions: [ IconButton(icon: const Icon(Icons.person_outline), onPressed: _showProfileModal), const SizedBox(width: 20) ],
      ),
      body: Row(children: [
        // TECLADO Y BUSCADOR (IZQUIERDA)
        Container(width: 320, color: Colors.black54, padding: const EdgeInsets.all(20), child: Column(children: [
          _vortexInput(label: "Buscando...", controller: _searchCtrl),
          const SizedBox(height: 20),
          Expanded(child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 5, crossAxisSpacing: 5),
            itemCount: 36,
            itemBuilder: (context, i) {
              String char = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"[i];
              return InkWell(onTap: () {
                setState(() {
                  _searchCtrl.text += char;
                  resultados = catalogo.where((e) => e.contains(_searchCtrl.text.toUpperCase())).toList();
                });
              }, child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)), child: Center(child: Text(char))));
            },
          )),
          _vortexButton(text: "BORRAR", color: Colors.redAccent, onTap: () {
            setState(() {
              if (_searchCtrl.text.isNotEmpty) {
                _searchCtrl.text = _searchCtrl.text.substring(0, _searchCtrl.text.length - 1);
                resultados = catalogo.where((e) => e.contains(_searchCtrl.text.toUpperCase())).toList();
              }
            });
          }),
        ])),
        // RESULTADOS PREDICTIVOS (DERECHA)
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(40),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.7, crossAxisSpacing: 20, mainAxisSpacing: 20),
          itemCount: resultados.length,
          itemBuilder: (context, i) => Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)), borderRadius: BorderRadius.circular(15)),
            child: Center(child: Text(resultados[i], textAlign: TextAlign.center)),
          ),
        ))
      ]),
    );
  }

  // --- COMPONENTES UI REUTILIZABLES ---
  Widget _vortexInput({required String label, bool obscure = false, TextEditingController? controller}) {
    return Container(margin: const EdgeInsets.symmetric(vertical: 8), child: TextField(controller: controller, obscureText: obscure, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))));
  }

  Widget _vortexButton({required String text, required VoidCallback? onTap, Color color = Colors.cyanAccent}) {
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: onTap, child: Text(text, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)));
  }

  void _showToast(String m) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))); }
}
