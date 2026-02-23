import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const VortexUltimateApp());
}

class VortexUltimateApp extends StatelessWidget {
  const VortexUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00050A),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
      home: const VortexAuthScreen(),
    );
  }
}

class VortexAuthScreen extends StatefulWidget {
  const VortexAuthScreen({super.key});

  @override
  State<VortexAuthScreen> createState() => _VortexAuthScreenState();
}

class _VortexAuthScreenState extends State<VortexAuthScreen> {
  // Vistas: 'login', 'registro', 'recuperar', 'verificar', 'nueva_pass'
  String currentView = 'login';
  String sourceView = ''; // Para saber si venimos de registro o recuperación
  
  // Lógica de Temporizador
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = true;

  // Controladores
  final TextEditingController _userController = TextEditingController(); // Email o ID
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _switchView(String view) {
    setState(() {
      currentView = view;
      _timer?.cancel();
      _canResend = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _userController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF001F2B), Color(0xFF00050A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("VORTEX", style: GoogleFonts.orbitron(fontSize: 50, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 10)),
                if (currentView == 'login') 
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("ID: 7420931", style: TextStyle(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 30),
                _buildFormBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormBox() {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: _buildCurrentInterface(),
    );
  }

  Widget _buildCurrentInterface() {
    switch (currentView) {
      case 'login': return _interfaceLogin();
      case 'registro': return _interfaceRegistroRecuperar(titulo: "REGISTRARSE", esRecuperar: false);
      case 'recuperar': return _interfaceRegistroRecuperar(titulo: "RECUPERAR CUENTA", esRecuperar: true);
      case 'verificar': return _interfaceVerificarCodigo();
      case 'nueva_pass': return _interfaceNuevaPassword();
      default: return _interfaceLogin();
    }
  }

  // --- INTERFAZ: LOGIN ---
  Widget _interfaceLogin() {
    return Column(
      children: [
        TextField(controller: _userController, decoration: const InputDecoration(hintText: "Correo Electrónico o ID")),
        const SizedBox(height: 15),
        TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(hintText: "Contraseña")),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () => print("Iniciando sesión..."),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
          child: const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () => _switchView('recuperar'), child: const Text("Olvidé mi contraseña", style: TextStyle(color: Colors.white38))),
            TextButton(onPressed: () => _switchView('registro'), child: const Text("Eres nuevo? Regístrate aquí", style: TextStyle(color: Colors.white70))),
          ],
        )
      ],
    );
  }

  // --- INTERFAZ: REGISTRO / RECUPERAR (SOLICITAR CÓDIGO) ---
  Widget _interfaceRegistroRecuperar({required String titulo, required bool esRecuperar}) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 25),
        TextField(controller: _userController, decoration: const InputDecoration(hintText: "Introduce tu Correo Electrónico")),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: TextField(controller: _codeController, decoration: const InputDecoration(hintText: "Código"))),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              height: 55,
              child: ElevatedButton(
                onPressed: _canResend ? () { _startTimer(); } : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                child: Text(_canResend ? "ENVIAR" : "$_secondsRemaining s", style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            sourceView = currentView;
            _switchView('verificar');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
          child: const Text("CONTINUAR"),
        ),
        TextButton(onPressed: () => _switchView('login'), child: const Text("Volver atrás")),
      ],
    );
  }

  // --- INTERFAZ: VERIFICAR CÓDIGO (LÓGICA) ---
  Widget _interfaceVerificarCodigo() {
    return Column(
      children: [
        const Text("VERIFICACIÓN", style: TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 20),
        const Text("Se ha enviado un código a tu correo.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => _switchView('nueva_pass'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
          child: const Text("VALIDAR CÓDIGO"),
        ),
      ],
    );
  }

  // --- INTERFAZ: NUEVA CONTRASEÑA ---
  Widget _interfaceNuevaPassword() {
    return Column(
      children: [
        Text(sourceView == 'registro' ? "DEFINIR CONTRASEÑA" : "CAMBIAR CONTRASEÑA", style: const TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 25),
        TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(hintText: "Nueva Contraseña")),
        const SizedBox(height: 15),
        TextField(controller: _confirmPassController, obscureText: true, decoration: const InputDecoration(hintText: "Confirmar Contraseña")),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            if (_passController.text == _confirmPassController.text) {
              _switchView('login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Las contraseñas no coinciden")));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
          child: const Text("FINALIZAR"),
        ),
      ],
    );
  }
}
