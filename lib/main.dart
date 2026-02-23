import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Modo inmersivo para TV y Celular
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const VortexUltimateApp());
}

class VortexUltimateApp extends StatelessWidget {
  const VortexUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vortex Premium',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00050A),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VortexSplashScreen(),
    );
  }
}

// =========================================================
// 1. VIDEO SPLASH (CARGA INICIAL)
// =========================================================
class VortexSplashScreen extends StatefulWidget {
  const VortexSplashScreen({super.key});

  @override
  State<VortexSplashScreen> createState() => _VortexSplashScreenState();
}

class _VortexSplashScreenState extends State<VortexSplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Reemplazar con el path real de tu video en assets
    _controller = VideoPlayerController.asset("assets/videos/vortex_intro.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        // Al terminar el video, vamos a la pantalla de Auth limpia
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) => const VortexAuthScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const CircularProgressIndicator(color: Colors.cyanAccent),
      ),
    );
  }
}

// =========================================================
// 2. INTERFAZ DE AUTENTICACIÓN (REGISTRO / LOGIN)
// ESTA INTERFAZ ESTÁ LIMPIA - SIN MENÚS NI LUPAS
// =========================================================
class VortexAuthScreen extends StatefulWidget {
  const VortexAuthScreen({super.key});

  @override
  State<VortexAuthScreen> createState() => _VortexAuthScreenState();
}

class _VortexAuthScreenState extends State<VortexAuthScreen> {
  bool isRegistering = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _processAuth() {
    // Simulación de éxito de registro/login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.cyanAccent,
        content: Text(
          isRegistering ? "¡Cuenta creada con éxito!" : "¡Inicio de sesión exitoso!",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // Solo tras el éxito, entramos al Menú Principal
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VortexMainMenu()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF001F2B), Color(0xFF00050A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "VORTEX",
                  style: GoogleFonts.orbitron(
                    fontSize: 60,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 15,
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isRegistering ? "REGISTRARSE" : "INICIAR SESIÓN",
                        style: GoogleFonts.lexend(fontSize: 20, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Correo Electrónico",
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.email, color: Colors.cyanAccent),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Contraseña",
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.lock, color: Colors.cyanAccent),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _processAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          isRegistering ? "CREAR CUENTA" : "ENTRAR",
                          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => setState(() => isRegistering = !isRegistering),
                        child: Text(
                          isRegistering ? "¿Ya tienes cuenta? Inicia Sesión" : "¿Eres nuevo? Regístrate aquí",
                          style: const TextStyle(color: Colors.white38),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// 3. MENÚ PRINCIPAL (SOLO ACCESIBLE POST-LOGIN)
// CON INTERFAZ COMPLETA: HORA, LUPA, HISTORIAL, PERFIL Y CATEGORÍAS
// =========================================================
class VortexMainMenu extends StatefulWidget {
  const VortexMainMenu({super.key});

  @override
  State<VortexMainMenu> createState() => _VortexMainMenuState();
}

class _VortexMainMenuState extends State<VortexMainMenu> {
  String _timeString = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat('HH:mm').format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FONDO GRADIENTE PREMIUM
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF000A0F), Colors.black],
              ),
            ),
          ),

          // --- BARRA SUPERIOR ---
          Positioned(
            top: 30,
            left: 0,
            right: 40,
            child: Row(
              children: [
                const Spacer(flex: 2),
                // Centro: Nombre de la Aplicación
                Text(
                  "VORTEX",
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                  ),
                ),
                const Spacer(),
                // Derecha: Hora e Iconos Funcionales
                Row(
                  children: [
                    Text(
                      _timeString,
                      style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white54),
                    ),
                    const SizedBox(width: 30),
                    _topIcon(Icons.search, "Búsqueda"),
                    _topIcon(Icons.history, "Historial"),
                    _topIcon(Icons.person, "Perfil"),
                  ],
                ),
              ],
            ),
          ),

          // --- MENÚ LATERAL IZQUIERDO ---
          Positioned(
            left: 0,
            top: 100,
            bottom: 0,
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black, Colors.black.withOpacity(0)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _sideMenuItem(Icons.movie, "PELÍCULAS"),
                  _sideMenuItem(Icons.tv, "SERIES"),
                  _sideMenuItem(Icons.auto_awesome, "ANIME"),
                  _sideMenuItem(Icons.live_tv, "TV VIVO"),
                ],
              ),
            ),
          ),

          // --- CONTENIDO DE ESTRENOS ---
          Positioned(
            left: 120,
            top: 120,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ESTRENOS DESTACADOS",
                  style: GoogleFonts.lexend(fontSize: 18, color: Colors.cyanAccent, letterSpacing: 2),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 25, bottom: 40),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                          image: const DecorationImage(
                            image: NetworkImage("https://via.placeholder.com/200x300/000B14/00E5FF?text=VORTEX+POSTER"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para iconos de la barra superior derecha
  Widget _topIcon(IconData icon, String tooltip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        tooltip: tooltip,
        onPressed: () {
          // Cada icono disparará su propia interfaz modal/pantalla
          print("Navegando a: $tooltip");
        },
      ),
    );
  }

  // Widget para items del menú lateral
  Widget _sideMenuItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 30),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        ],
      ),
    );
  }
}
