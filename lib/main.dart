import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Vortex Premium Network',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00050A),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent)),
        ),
      ),
      home: const VortexAuthScreen(),
    );
  }
}

// ======================================================
// 1. SISTEMA DE ACCESO Y SEGURIDAD
// ======================================================
class VortexAuthScreen extends StatefulWidget {
  const VortexAuthScreen({super.key});

  @override
  State<VortexAuthScreen> createState() => _VortexAuthScreenState();
}

class _VortexAuthScreenState extends State<VortexAuthScreen> {
  String currentView = 'login'; 
  String? _assignedID; 
  String? _generatedOTP;

  final TextEditingController _userController = TextEditingController(); 
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _generateNumericID() {
    final random = Random();
    String id = "";
    for (int i = 0; i < 7; i++) id += random.nextInt(10).toString();
    return id;
  }

  Future<void> _sendVortexEmail(String target, String mode) async {
    _generatedOTP = (Random().nextInt(900000) + 100000).toString();
    const serviceId = 'service_w4zcrli';
    const templateId = 'template_rbyu42h';
    const publicKey = 'PRoX1Ao5_SrB4sncc';

    _showVortexSnack("Iniciando protocolos de seguridad...", Colors.blueGrey);

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'user_email': target,
            'codigo_vortex': _generatedOTP,
            'request_type': mode
          }
        }),
      );

      if (response.statusCode == 200) {
        _showVortexSnack("Código enviado a $target", Colors.green);
        setState(() => currentView = 'verificar');
      }
    } catch (e) {
      _showVortexSnack("Error de conexión.", Colors.redAccent);
    }
  }

  void _showVortexSnack(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment.center, radius: 1.3, colors: [Color(0xFF001F2B), Color(0xFF00050A)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 65, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 15, shadows: [const Shadow(color: Colors.cyanAccent, blurRadius: 25)])),
                const SizedBox(height: 50),
                _buildMainContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
      child: _renderCurrentInterface(),
    );
  }

  Widget _renderCurrentInterface() {
    switch (currentView) {
      case 'login': return _interfaceLogin();
      case 'registro': return _interfaceEmailInput("NUEVO REGISTRO");
      case 'recuperar': return _interfaceEmailInput("RECUPERAR CLAVE");
      case 'verificar': return _interfaceVerificar();
      case 'nueva_pass': return _interfaceNuevaPass();
      case 'registro_exitoso': return _interfaceRegistroOk();
      default: return _interfaceLogin();
    }
  }

  Widget _interfaceLogin() {
    return Column(
      children: [
        Text("SISTEMA DE ACCESO", style: GoogleFonts.orbitron(fontSize: 14, color: Colors.white38, letterSpacing: 2)),
        const SizedBox(height: 40),
        TextField(controller: _userController, decoration: const InputDecoration(hintText: "Email o Usuario")),
        const SizedBox(height: 20),
        TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(hintText: "Contraseña")),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VortexHomeScreen(userEmail: _userController.text, userID: _assignedID ?? "9928374"))),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          child: const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => currentView = 'registro'), child: const Text("REGISTRARSE", style: TextStyle(color: Colors.cyanAccent))),
          TextButton(onPressed: () => setState(() => currentView = 'recuperar'), child: const Text("¿Problemas?", style: TextStyle(color: Colors.white24))),
        ])
      ],
    );
  }

  Widget _interfaceEmailInput(String title) {
    return Column(children: [
      Text(title, style: GoogleFonts.orbitron(fontSize: 18)),
      const SizedBox(height: 30),
      TextField(controller: _emailController, decoration: const InputDecoration(hintText: "Tu correo")),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () => _sendVortexEmail(_emailController.text, title), child: const Text("ENVIAR CÓDIGO")),
      TextButton(onPressed: () => setState(() => currentView = 'login'), child: const Text("Volver"))
    ]);
  }

  Widget _interfaceVerificar() {
    return Column(children: [
      Text("VERIFICACIÓN", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
      const SizedBox(height: 30),
      TextField(controller: _codeController, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22), decoration: const InputDecoration(hintText: "000000")),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () => setState(() => currentView = 'nueva_pass'), child: const Text("VERIFICAR"))
    ]);
  }

  Widget _interfaceNuevaPass() {
    return Column(children: [
      Text("NUEVA CONTRASEÑA", style: GoogleFonts.orbitron()),
      const SizedBox(height: 30),
      TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(hintText: "Contraseña")),
      const SizedBox(height: 10),
      TextField(controller: _confirmPassController, obscureText: true, decoration: const InputDecoration(hintText: "Confirmar")),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () { _assignedID = _generateNumericID(); setState(() => currentView = 'registro_exitoso'); }, child: const Text("GUARDAR"))
    ]);
  }

  Widget _interfaceRegistroOk() {
    return Column(children: [
      const Icon(Icons.verified, color: Colors.cyanAccent, size: 60),
      const SizedBox(height: 20),
      const Text("PERFIL ACTIVADO"),
      const SizedBox(height: 30),
      ElevatedButton(onPressed: () => setState(() => currentView = 'login'), child: const Text("IR AL LOGIN"))
    ]);
  }
}

// ======================================================
// 2. INTERFAZ PRINCIPAL VORTEX (HOME)
// ======================================================
class VortexHomeScreen extends StatefulWidget {
  final String userEmail;
  final String userID;
  const VortexHomeScreen({super.key, required this.userEmail, required this.userID});

  @override
  State<VortexHomeScreen> createState() => _VortexHomeScreenState();
}

class _VortexHomeScreenState extends State<VortexHomeScreen> {
  int _tabIndex = 0; // 0:TV, 1:Destacados, 2:Pelis, 3:Series, 4:Kids, 5:Anime, 6:Cuenta, 7:Historial
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _generos = ["ACCIÓN", "DRAMA", "COMEDIA", "TERROR", "CIENCIA FICCIÓN", "ROMANCE", "DOCUMENTAL", "ANIMACIÓN"];

  void _showVortexSnack(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _renderView()),
                  ],
                ),
              ),
            ],
          ),
          if (_isSearching) _buildTVExpandedSearch(),
        ],
      ),
    );
  }

  // --- HEADER SUPERIOR ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          const Spacer(),
          IconButton(icon: const Icon(Icons.search, color: Colors.cyanAccent, size: 28), onPressed: () => setState(() => _isSearching = true)),
          IconButton(icon: const Icon(Icons.history, color: Colors.cyanAccent, size: 28), onPressed: () => setState(() => _tabIndex = 7)),
          const SizedBox(width: 30),
          const Icon(Icons.wifi, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // --- SIDEBAR (ORDEN SOLICITADO) ---
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFF00080C),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 24, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 5)),
          const SizedBox(height: 50),
          _sidebarItem(0, Icons.tv, "TV EN VIVO"),
          _sidebarItem(1, Icons.auto_awesome, "DESTACADOS"),
          _sidebarItem(2, Icons.movie_outlined, "PELÍCULAS"),
          _sidebarItem(3, Icons.live_tv_rounded, "SERIES"),
          _sidebarItem(4, Icons.child_care, "KIDS"),
          _sidebarItem(5, Icons.adb, "ANIME"),
          const Spacer(),
          _sidebarItem(6, Icons.person_pin, "MI CUENTA"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(int i, IconData icon, String label) {
    bool sel = _tabIndex == i;
    return InkWell(
      onTap: () => setState(() { _tabIndex = i; _isSearching = false; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: sel ? Colors.cyanAccent : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: sel ? Colors.black : Colors.white54, size: 22),
          const SizedBox(width: 15),
          Text(label, style: TextStyle(color: sel ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    );
  }

  // ======================================================
  // 3. SECCIONES DE CONTENIDO
  // ======================================================
  Widget _renderView() {
    switch (_tabIndex) {
      case 0: return _viewTV();
      case 1: return _viewDestacados();
      case 2: return _viewGrid("PELÍCULAS");
      case 3: return _viewGrid("SERIES");
      case 4: return _viewGrid("KIDS");
      case 5: return _viewGrid("ANIME");
      case 6: return _viewAccount();
      case 7: return _viewHistory();
      default: return _viewDestacados();
    }
  }

  // --- BUSCADOR EXPANDIDO TV ---
  Widget _buildTVExpandedSearch() {
    return Container(
      color: Colors.black.withValues(alpha: 0.98),
      child: Row(
        children: [
          // TECLADO IZQUIERDO
          Container(
            width: 450,
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white10))),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 22),
                  decoration: InputDecoration(
                    hintText: "BUSCAR...",
                    prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                    suffixIcon: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _isSearching = false)),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: _customTVKeyboard()),
              ],
            ),
          ),
          // GÉNEROS Y RESULTADOS DERECHA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GÉNEROS", style: GoogleFonts.orbitron(color: Colors.white38, letterSpacing: 2, fontSize: 12)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _generos.map((g) => InkWell(
                      onTap: () => _showVortexSnack("Filtrando por: $g", Colors.cyan),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(20)),
                        child: Text(g, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 40),
                  const Text("Sugerencias para ti", style: TextStyle(color: Colors.white24)),
                  const Expanded(child: Center(child: Icon(Icons.movie_creation_outlined, size: 100, color: Colors.white10))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _customTVKeyboard() {
    final keys = [
      ["A", "B", "C", "D", "E", "F"],
      ["G", "H", "I", "J", "K", "L"],
      ["M", "N", "O", "P", "Q", "R"],
      ["S", "T", "U", "V", "W", "X"],
      ["Y", "Z", "1", "2", "3", "4"],
      ["5", "6", "7", "8", "9", "0"],
    ];

    return Column(
      children: [
        ...keys.map((row) => Expanded(
          child: Row(
            children: row.map((k) => Expanded(child: InkWell(
              onTap: () => _searchController.text += k,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text(k, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ))).toList(),
          ),
        )),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _keyAction("BORRAR", () {
              if (_searchController.text.isNotEmpty) {
                _searchController.text = _searchController.text.substring(0, _searchController.text.length - 1);
              }
            }, Colors.orangeAccent)),
            Expanded(child: _keyAction("LIMPIAR", () => _searchController.clear(), Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 5),
        _keyAction("BUSCAR AHORA", () => setState(() => _isSearching = false), Colors.cyanAccent, isDark: true),
      ],
    );
  }

  Widget _keyAction(String label, VoidCallback tap, Color color, {bool isDark = false}) {
    return InkWell(
      onTap: tap,
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 1.0 : 0.2), borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isDark ? Colors.black : color, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  // --- VISTA HISTORIAL ---
  Widget _viewHistory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.history, color: Colors.cyanAccent, size: 30),
            const SizedBox(width: 15),
            Text("HISTORIAL DE REPRODUCCIÓN", style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.4),
            itemBuilder: (c, i) => Container(
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.play_arrow, color: Colors.white24)),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 4, color: Colors.white10,
                      child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.6, child: Container(color: Colors.cyanAccent)),
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

  // --- VISTA DESTACADOS (CARTELES GIGANTES) ---
  Widget _viewDestacados() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ESTRENOS RECIENTES", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 3, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _featuredBanner("https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=2070", "CÓDIGO VORTEX")),
              const SizedBox(width: 20),
              Expanded(child: _featuredBanner("https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=1925", "MUNDO ANIME 2026")),
            ],
          ),
          const SizedBox(height: 40),
          _contentRow("TENDENCIAS"),
          _contentRow("LO MÁS VISTO"),
        ],
      ),
    );
  }

  Widget _featuredBanner(String url, String title) {
    return Container(
      height: 320,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: const LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent])),
        padding: const EdgeInsets.all(30),
        alignment: Alignment.bottomLeft,
        child: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      ),
    );
  }

  // --- VISTA TV EN VIVO (CORREGIDO ERROR CONST) ---
  Widget _viewTV() {
    return Row(
      children: [
        Expanded(flex: 3, child: Container(margin: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)), child: const Center(child: Icon(Icons.play_circle_fill, size: 80, color: Colors.cyanAccent)))),
        Container(
          width: 320, margin: const EdgeInsets.only(right: 30, top: 30, bottom: 30),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(30)),
          child: Column(children: [
            const Padding(padding: EdgeInsets.all(25), child: Text("DIRECTOS")),
            Expanded(child: ListView(children: [
              _channelItem("🇦🇷", "Argentina TV"),
              _channelItem("🇲🇽", "México Live"),
              _channelItem("⚽", "Vortex Sports"),
            ])),
          ]),
        )
      ],
    );
  }

  Widget _channelItem(String emoji, String name) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(name),
      onTap: () {},
    );
  }

  // --- FILAS DE CONTENIDO (7 ITEMS POR FILA) ---
  Widget _viewGrid(String title) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.orbitron(fontSize: 26, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _contentRow("POPULARES EN TU ZONA"),
          _contentRow("RECIÉN AÑADIDOS"),
          _contentRow("BASADO EN TUS GUSTOS"),
        ],
      ),
    );
  }

  Widget _contentRow(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 20, bottom: 10), child: Text(title, style: const TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2))),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 15,
            itemBuilder: (c, i) => Container(
              width: 130, // Proporción para que entren 7 en pantalla TV
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15)),
              child: const Center(child: Icon(Icons.play_arrow, color: Colors.white10)),
            ),
          ),
        ),
      ],
    );
  }

  // --- VISTA MI CUENTA ---
  Widget _viewAccount() {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("AJUSTES DE CUENTA", style: GoogleFonts.orbitron(fontSize: 24, color: Colors.cyanAccent)),
          const SizedBox(height: 40),
          _accountInfo("ID VORTEX", widget.userID),
          _accountInfo("EMAIL", widget.userEmail),
          _accountInfo("CONTRASEÑA", "••••••••••••"),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const VortexAuthScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), foregroundColor: Colors.redAccent, minimumSize: const Size(200, 50)),
            child: const Text("CERRAR SESIÓN"),
          )
        ],
      ),
    );
  }

  Widget _accountInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10)), const SizedBox(height: 5), Text(value, style: const TextStyle(fontSize: 18))]),
          const Text("MODIFICAR", style: TextStyle(color: Colors.white24, fontSize: 11)),
        ],
      ),
    );
  }
}
