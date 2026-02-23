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
  // Experiencia inmersiva total (oculta barras de sistema)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent, brightness: Brightness.dark),
      ),
      home: const VortexSplash(),
    );
  }
}

// --- 1. INTRO CINEMATOGRÁFICA (SPLASH VIDEO) ---
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
          pageBuilder: (_, __, ___) => const MasterCore(),
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

// --- 2. NÚCLEO TOTAL DE LA APLICACIÓN ---
class MasterCore extends StatefulWidget {
  const MasterCore({super.key});
  @override
  State<MasterCore> createState() => _MasterCoreState();
}

class _MasterCoreState extends State<MasterCore> {
  // --- VARIABLES DE ESTADO ---
  bool isLoggedIn = false;
  String hardwareID = "DETECTOR-VORTEX-ID";
  String userEmail = "usuario@vortex.com";
  String userPass = "123456";
  String currentTime = "";

  // --- CATÁLOGO Y BUSQUEDA ---
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> catalogo = ["AVENGERS", "BATMAN", "NARUTO", "ONE PIECE", "SPIDERMAN", "STRANGER THINGS", "ANIME: BLEACH", "FROZEN", "DRAGON BALL", "EL REY LEON"];
  List<String> resultadosBusqueda = [];

  // --- HISTORIAL CRONOLÓGICO REAL ---
  List<String> historial = []; // Lo último visto siempre en el índice 0

  @override
  void initState() {
    super.initState();
    _initSystem();
    Timer.periodic(const Duration(seconds: 1), (t) => setState(() => currentTime = DateFormat('HH:mm:ss').format(DateTime.now())));
  }

  void _initSystem() async {
    final info = await DeviceInfoPlugin().androidInfo;
    setState(() => hardwareID = info.id.toUpperCase());
  }

  // --- SISTEMA DE NOTIFICACIONES (TOASTS) ---
  void _vortexNotify(String titulo, String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF00151C), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(msg, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ])),
        ]),
      ),
    ));
  }

  // --- LÓGICA DE REPRODUCCIÓN E HISTORIAL ---
  void _reproducirPelicula(String title) {
    setState(() {
      historial.remove(title); // Si ya existe, lo quitamos de su posición anterior
      historial.insert(0, title); // Lo insertamos en la posición 0 (Cronología Actual)
    });
    _vortexNotify("Reproduciendo", "Disfruta de $title", Icons.play_circle_fill, Colors.cyanAccent);
  }

  // --- FLUJO COMPLETO DE RECUPERACIÓN (OLVIDÉ CONTRASEÑA) ---
  void _openRecoveryFlow() {
    showGeneralDialog(context: context, barrierColor: Colors.black.withOpacity(0.95), pageBuilder: (c, a, b) => Center(
      child: Material(color: Colors.transparent, child: Container(
        width: 400, padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(color: const Color(0xFF000A0F), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.cyanAccent.withOpacity(0.5))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("RECUPERAR", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18)),
          const SizedBox(height: 25),
          _vortexInput(label: "Ingresa tu email", icon: Icons.email_outlined),
          const SizedBox(height: 30),
          _vortexButton(text: "ENVIAR CÓDIGO", onTap: () {
            Navigator.pop(c);
            _vortexNotify("Código Enviado", "Revisa tu bandeja de entrada", Icons.mail, Colors.amberAccent);
            _openVerifyCode();
          }),
        ]),
      )),
    ));
  }

  void _openVerifyCode() {
    showGeneralDialog(context: context, barrierColor: Colors.black, pageBuilder: (c, a, b) => Center(
      child: Material(color: Colors.transparent, child: Container(
        width: 400, padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(color: const Color(0xFF000A0F), borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("CÓDIGO DE SEGURIDAD"),
          _vortexInput(label: "000000", icon: Icons.security),
          const SizedBox(height: 20),
          _vortexButton(text: "VERIFICAR", onTap: () { Navigator.pop(c); _openNewPass(); }),
        ]),
      )),
    ));
  }

  void _openNewPass() {
    showGeneralDialog(context: context, barrierColor: Colors.black, pageBuilder: (c, a, b) => Center(
      child: Material(color: Colors.transparent, child: Container(
        width: 400, padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(color: const Color(0xFF000A0F), borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("NUEVA CONTRASEÑA"),
          _vortexInput(label: "Escribe la nueva clave", obscure: true, icon: Icons.lock),
          const SizedBox(height: 30),
          _vortexButton(text: "FINALIZAR", onTap: () {
            Navigator.pop(c);
            _vortexNotify("Éxito", "Contraseña cambiada exitosamente", Icons.check_circle, Colors.greenAccent);
          }),
        ]),
      )),
    ));
  }

  // --- INTERFAZ PRINCIPAL (HOME / LOGIN) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        child: isLoggedIn ? _buildHome() : _buildLogin(),
      ),
    );
  }

  Widget _buildLogin() {
    return Container(
      decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.2, colors: [Color(0xFF001A25), Color(0xFF00050A)])),
      child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(40), child: Column(children: [
        Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 60, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 15)),
        const SizedBox(height: 50),
        Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
          child: Column(children: [
            _vortexInput(label: "Email / Usuario", icon: Icons.person_outline),
            _vortexInput(label: "Contraseña", icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 30),
            _vortexButton(text: "INICIAR SESIÓN", onTap: () {
              setState(() => isLoggedIn = true);
              _vortexNotify("Acceso Exitoso", "Bienvenido de nuevo", Icons.verified, Colors.cyanAccent);
            }),
            TextButton(onPressed: _openRecoveryFlow, child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.white38))),
          ]),
        )
      ]))),
    );
  }

  Widget _buildHome() {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Row(children: [
      // SIDEBAR PROFESIONAL
      Container(width: 80, color: Colors.black, child: Column(children: [
        const SizedBox(height: 40),
        _sideIcon(Icons.search, _showSearch),
        _sideIcon(Icons.history, _showHistory),
        _sideIcon(Icons.person_pin, _showProfile),
        const Spacer(),
        _sideIcon(Icons.logout, () => setState(() => isLoggedIn = false)),
        const SizedBox(height: 20),
      ])),
      // DASHBOARD
      Expanded(child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("VORTEX HOME", style: GoogleFonts.orbitron(fontSize: 25, color: Colors.cyanAccent)),
            Text(currentTime, style: GoogleFonts.orbitron(color: Colors.white12, fontSize: 20)),
          ]),
          const SizedBox(height: 50),
          if (historial.isNotEmpty) ...[
            Text("VISTO RECIENTEMENTE", style: GoogleFonts.lexend(letterSpacing: 2, color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(height: 160, child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: historial.length,
              itemBuilder: (c, i) => _cardPoster(historial[i], isHistorial: true),
            )),
            const SizedBox(height: 40),
          ],
          Text("CATÁLOGO PARA TI", style: GoogleFonts.lexend(letterSpacing: 2, color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 5 : 2, childAspectRatio: 0.7, crossAxisSpacing: 20, mainAxisSpacing: 20),
            itemCount: catalogo.length,
            itemBuilder: (c, i) => _cardPoster(catalogo[i]),
          ))
        ]),
      ))
    ]);
  }

  // --- MODAL DE PERFIL (ID BLOQUEADO) ---
  void _showProfile() {
    showGeneralDialog(context: context, barrierColor: Colors.black87, pageBuilder: (c, a, b) => Center(
      child: Material(color: Colors.transparent, child: Container(
        width: 500, padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: const Color(0xFF000A0F), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.cyanAccent, child: Icon(Icons.person, size: 50, color: Colors.black)),
          const SizedBox(height: 30),
          _profileRow("ID DISPOSITIVO (BLOQUEADO)", hardwareID, false),
          _profileRow("CORREO", userEmail, true),
          _profileRow("PASSWORD", "********", true),
          const SizedBox(height: 40),
          _vortexButton(text: "VOLVER", onTap: () => Navigator.pop(c)),
        ]),
      )),
    ));
  }

  void _showSearch() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF00050A), builder: (c) => Padding(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        _vortexInput(label: "Buscar...", icon: Icons.search, controller: _searchCtrl, onChanged: (v) {
          setState(() => resultadosBusqueda = catalogo.where((e) => e.contains(v.toUpperCase())).toList());
        }),
        const SizedBox(height: 30),
        Expanded(child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.7, crossAxisSpacing: 20),
          itemCount: resultadosBusqueda.length,
          itemBuilder: (c, i) => _cardPoster(resultadosBusqueda[i]),
        ))
      ]),
    ));
  }

  void _showHistory() {
    _vortexNotify("Historial", "Mostrando tus últimas vistas", Icons.history, Colors.blueAccent);
  }

  // --- WIDGETS DE SOPORTE ---
  Widget _cardPoster(String t, {bool isHistorial = false}) {
    return InkWell(
      onTap: () => _reproducirPelicula(t),
      child: Container(
        width: 120, margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: isHistorial ? Colors.cyanAccent.withOpacity(0.3) : Colors.white10)),
        child: Center(child: Text(t, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _sideIcon(IconData i, VoidCallback onTap) => IconButton(icon: Icon(i, color: Colors.white38, size: 28), onPressed: onTap);

  Widget _profileRow(String l, String v, bool ed) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: const TextStyle(color: Colors.white24, fontSize: 10)),
        Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      const Spacer(),
      Icon(ed ? Icons.edit : Icons.lock, color: ed ? Colors.cyanAccent : Colors.white12, size: 20),
    ]));
  }

  Widget _vortexInput({required String label, IconData? icon, bool obscure = false, TextEditingController? controller, Function(String)? onChanged}) {
    return Container(margin: const EdgeInsets.symmetric(vertical: 10), child: TextField(controller: controller, onChanged: onChanged, obscureText: obscure, decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.cyanAccent), labelText: label, filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))));
  }

  Widget _vortexButton({required String text, required VoidCallback onTap, Color color = Colors.cyanAccent}) {
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: onTap, child: Text(text, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)));
  }
}
