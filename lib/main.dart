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
  // Forzamos que la app sea inmersiva (sin barras de sistema)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent, brightness: Brightness.dark),
      ),
      home: const VortexSplash(),
    );
  }
}

// --- 1. INTRO CINEMATOGRÁFICA ---
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
        Navigator.pushReplacement(context, PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const VortexMasterCore(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ));
      }
    });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Center(child: _controller.value.isInitialized ? SizedBox.expand(child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: _controller.value.size.width, height: _controller.value.size.height, child: VideoPlayer(_controller)))) : const CircularProgressIndicator(color: Colors.cyanAccent)));
  }
}

// --- 2. EL NÚCLEO (CORE) DEL SISTEMA ---
class VortexMasterCore extends StatefulWidget {
  const VortexMasterCore({super.key});
  @override
  State<VortexMasterCore> createState() => _VortexMasterCoreState();
}

class _VortexMasterCoreState extends State<VortexMasterCore> {
  // Estados Globales
  bool isLoggedIn = false;
  bool showRegister = false;
  String hardwareID = "DETECTANDO...";
  String localTime = "";
  
  // Datos de Usuario (Persistencia simulada)
  String userEmail = "usuario@vortex.com";
  String userPass = "123456";

  // Buscador y Catálogo
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> catalogo = ["AVENGERS", "BATMAN", "NARUTO", "ONE PIECE", "SPIDERMAN", "STRANGER THINGS", "AVATAR", "DRAGON BALL", "BLEACH", "FROZEN"];
  List<String> resultadosBusqueda = [];

  // Historial Cronológico Real (Lo más nuevo arriba)
  List<String> historialCronologico = [];

  @override
  void initState() {
    super.initState();
    _loadDevice();
    Timer.periodic(const Duration(seconds: 1), (t) => setState(() => localTime = DateFormat('HH:mm').format(DateTime.now())));
  }

  Future<void> _loadDevice() async {
    final info = await DeviceInfoPlugin().androidInfo;
    setState(() => hardwareID = info.id.toUpperCase());
  }

  // --- LÓGICA DE ACCIONES ---
  void _login() {
    setState(() => isLoggedIn = true);
    _vortexNotify("Sesión Iniciada", "Bienvenido a la experiencia Vortex", Icons.verified_user, Colors.cyanAccent);
    // Aquí se activaría el audio: _playWelcomeSound();
  }

  void _watchMovie(String title) {
    setState(() {
      historialCronologico.remove(title); // Evita duplicados en otras posiciones
      historialCronologico.insert(0, title); // Agrega al inicio (lo más reciente)
    });
    _vortexNotify("Reproduciendo", "Disfruta de $title", Icons.play_arrow, Colors.greenAccent);
  }

  // --- COMPONENTES RESPONSIVOS ---
  double dynamicSize(double size) {
    double width = MediaQuery.of(context).size.width;
    return width > 1000 ? size : size * 0.8;
  }

  // --- INTERFAZ DE USUARIO ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: isLoggedIn ? _buildHome() : _buildAuth(),
      ),
    );
  }

  // --- LOGIN / REGISTER (ESTILO HBO MAX) ---
  Widget _buildAuth() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF001218), Color(0xFF00050A)]),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(children: [
            Text("VORTEX", style: GoogleFonts.orbitron(fontSize: dynamicSize(60), color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 12)),
            const SizedBox(height: 10),
            Text("PREMIUM STREAMING", style: GoogleFonts.lexend(fontSize: 12, color: Colors.white24, letterSpacing: 4)),
            const SizedBox(height: 50),
            Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
              child: Column(children: [
                _vortexInput(label: "Email o ID de Usuario", icon: Icons.alternate_email),
                _vortexInput(label: "Contraseña", icon: Icons.lock_outline, obscure: true),
                const SizedBox(height: 30),
                _vortexButton(text: "INGRESAR", onTap: _login),
                TextButton(onPressed: _recoveryFlow, child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.white38))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // --- HOME (ESTILO NETFLIX/DISNEY+) ---
  Widget _buildHome() {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Row(children: [
      // Sidebar Adaptativo
      Container(
        width: isTV ? 80 : 60,
        decoration: const BoxDecoration(color: Colors.black, border: Border(right: BorderSide(color: Colors.white10))),
        child: Column(children: [
          const SizedBox(height: 30),
          _navIcon(Icons.search, _showSearchDialog),
          _navIcon(Icons.history, _showHistoryDialog),
          _navIcon(Icons.person_outline, _showProfileDialog),
          const Spacer(),
          _navIcon(Icons.power_settings_new, () => setState(() => isLoggedIn = false)),
          const SizedBox(height: 20),
        ]),
      ),
      // Feed Principal
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("VORTEX HOME", style: GoogleFonts.orbitron(fontSize: 22, color: Colors.cyanAccent)),
              Text(localTime, style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white12)),
            ]),
            const SizedBox(height: 40),
            if (historialCronologico.isNotEmpty) ...[
              Text("CONTINUAR VIENDO", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: historialCronologico.length,
                  itemBuilder: (c, i) => _moviePoster(historialCronologico[i], isHistory: true),
                ),
              ),
              const SizedBox(height: 40),
            ],
            Text("TENDENCIAS", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 5 : 2, childAspectRatio: 0.7, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemCount: catalogo.length,
                itemBuilder: (c, i) => _moviePoster(catalogo[i]),
              ),
            ),
          ]),
        ),
      )
    ]);
  }

  // --- MODALES PROFESIONALES ---
  void _showProfileDialog() {
    showGeneralDialog(context: context, barrierColor: Colors.black.withOpacity(0.95), pageBuilder: (c, a, b) => Center(
      child: Material(color: Colors.transparent, child: Container(
        width: 500, padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: const Color(0xFF000A0F), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.cyanAccent.withOpacity(0.2))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 45, backgroundColor: Colors.cyanAccent, child: Icon(Icons.person, size: 40, color: Colors.black)),
          const SizedBox(height: 30),
          _profileItem("ID ÚNICO HARDWARE", hardwareID, false),
          _profileItem("CORREO ELECTRÓNICO", userEmail, true, onEdit: () => _editDialog("Email")),
          _profileItem("CONTRASEÑA", "********", true, onEdit: _securityPassFlow),
          const SizedBox(height: 40),
          _vortexButton(text: "VOLVER AL MENÚ", onTap: () => Navigator.pop(context)),
        ]),
      )),
    ));
  }

  void _showSearchDialog() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF00050A), builder: (c) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        _vortexInput(label: "Buscar en Vortex...", icon: Icons.search, controller: _searchCtrl, onChanged: (v) {
          setState(() => resultadosBusqueda = catalogo.where((e) => e.contains(v.toUpperCase())).toList());
        }),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.7, crossAxisSpacing: 20, mainAxisSpacing: 20),
            itemCount: resultadosBusqueda.length,
            itemBuilder: (c, i) => _moviePoster(resultadosBusqueda[i]),
          ),
        )
      ]),
    ));
  }

  // --- WIDGETS DE ESTILO VORTEX ---
  Widget _moviePoster(String title, {bool isHistory = false}) {
    return InkWell(
      onTap: () => _watchMovie(title),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isHistory ? Colors.cyanAccent.withOpacity(0.3) : Colors.white10),
          image: const DecorationImage(image: NetworkImage("https://via.placeholder.com/300x450/00050A/00E5FF?text=POSTER"), fit: BoxFit.cover),
        ),
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)])),
          child: Text(title, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _profileItem(String label, String val, bool editable, {VoidCallback? onEdit}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
        Text(val, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      const Spacer(),
      if (editable) IconButton(icon: const Icon(Icons.edit_note, color: Colors.cyanAccent), onPressed: onEdit)
      else const Icon(Icons.verified, size: 18, color: Colors.white10),
    ]));
  }

  Widget _vortexInput({required String label, IconData? icon, bool obscure = false, TextEditingController? controller, Function(String)? onChanged}) {
    return Container(margin: const EdgeInsets.symmetric(vertical: 10), child: TextField(controller: controller, onChanged: onChanged, obscureText: obscure, style: const TextStyle(fontSize: 14), decoration: InputDecoration(prefixIcon: Icon(icon, size: 18, color: Colors.cyanAccent), labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1)))));
  }

  Widget _vortexButton({required String text, required VoidCallback onTap, Color color = Colors.cyanAccent}) {
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: color.withOpacity(0.5), width: 2))), onPressed: onTap, child: Text(text, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 13)));
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: IconButton(icon: Icon(icon, color: Colors.white54, size: 28), onPressed: onTap));
  }

  void _vortexNotify(String title, String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.transparent, elevation: 0, content: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF001218), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))), child: Row(children: [Icon(icon, color: color), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(msg, style: const TextStyle(fontSize: 12, color: Colors.white54))])]))));
  }

  // --- FLUJOS DE SEGURIDAD ---
  void _recoveryFlow() { /* Lógica de recuperación de contraseña */ }
  void _securityPassFlow() { /* Lógica de validar password antes de cambiar */ }
  void _editDialog(String campo) { /* Diálogo para cambiar email */ }
  void _showHistoryDialog() { /* Muestra el historial cronológico completo */ }
}
