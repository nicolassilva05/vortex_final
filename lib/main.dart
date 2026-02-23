import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const VortexUltimateApp());
}

class VortexUltimateApp extends StatelessWidget {
  const VortexUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vortex Premium Streaming',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00050A),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white10, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.cyanAccent, width: 1),
          ),
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
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
  // Lógica de navegación de vistas
  String currentView = 'login';
  String sourceView = ''; 
  String? codigoGenerado; 
  
  // Variables del Temporizador
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = true;

  // Controladores de los campos de texto
  final TextEditingController _userController = TextEditingController(); 
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // --- FUNCIÓN DE ENVÍO POR EMAILJS (Sincronizada con image_c6bc79.png) ---
  Future<void> _enviarEmailReal(String emailDestino) async {
    codigoGenerado = (Random().nextInt(900000) + 100000).toString();
    
    // TUS DATOS REALES DE TU ÚLTIMA CAPTURA
    const serviceId = 'service_w4zcrli'; 
    const templateId = 'template_rbyu42h'; 
    const publicKey = 'PRoX1Ao5_SrB4sncc'; 

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    // SNACKBAR PREMIUM DE CARGA
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text("Sincronizando con Vortex... Enviando código a $emailDestino")),
          ],
        ),
        backgroundColor: const Color(0xFF001F2B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'user_email': emailDestino,
            'codigo_vortex': codigoGenerado,
          }
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Código de acceso enviado! Revisa tu bandeja de entrada."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        debugPrint("Error API: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error Red: $e");
    }
  }

  void _startTimer() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingresa un mail personal válido.")),
      );
      return;
    }

    _enviarEmailReal(_emailController.text);
    
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
      _codeController.clear();
      _passController.clear();
      _confirmPassController.clear();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _userController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FONDO RADIAL PREMIUM (SIN RECORTES)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF001F2B), Color(0xFF00050A)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO VORTEX CON EFECTO NEÓN
                  Text(
                    "VORTEX",
                    style: GoogleFonts.orbitron(
                      fontSize: 65,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                      shadows: [
                        const Shadow(color: Colors.cyanAccent, blurRadius: 25),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "ULTIMATE ENTERTAINMENT",
                    style: TextStyle(
                      color: Colors.cyanAccent.withValues(alpha: 0.4),
                      fontSize: 10,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildFormBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBox() {
    return Container(
      width: 480,
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 50,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildCurrentInterface(),
      ),
    );
  }

  Widget _buildCurrentInterface() {
    switch (currentView) {
      case 'login': return _interfaceLogin();
      case 'registro': return _interfaceEmailYCodigo(titulo: "NUEVO REGISTRO");
      case 'recuperar': return _interfaceEmailYCodigo(titulo: "RECUPERACIÓN");
      case 'nueva_pass': return _interfaceNuevaPassword();
      default: return _interfaceLogin();
    }
  }

  Widget _interfaceLogin() {
    return Column(
      key: const ValueKey("login"),
      children: [
        TextField(
          controller: _userController, 
          decoration: const InputDecoration(hintText: "Usuario o Email")
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passController, 
          obscureText: true, 
          decoration: const InputDecoration(hintText: "Contraseña")
        ),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: () => _showSnackBar("Validando credenciales en la red Vortex...", Colors.cyan),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 65),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 15,
            shadowColor: Colors.cyanAccent.withValues(alpha: 0.4),
          ),
          child: const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _switchView('recuperar'), 
              child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.white24, fontSize: 11))
            ),
            TextButton(
              onPressed: () => _switchView('registro'), 
              child: const Text("REGISTRARSE", style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold))
            ),
          ],
        )
      ],
    );
  }

  Widget _interfaceEmailYCodigo({required String titulo}) {
    return Column(
      key: ValueKey(titulo),
      children: [
        Text(titulo, style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 3)),
        const SizedBox(height: 10),
        const Text("Verifica tu identidad para continuar", style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 40),
        TextField(
          controller: _emailController, 
          decoration: const InputDecoration(hintText: "Tu mail personal")
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController, 
                decoration: const InputDecoration(hintText: "Código OTP")
              )
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 130,
              height: 65,
              child: ElevatedButton(
                onPressed: _canResend ? _startTimer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canResend ? Colors.white10 : Colors.transparent,
                  side: BorderSide(color: _canResend ? Colors.cyanAccent : Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  _canResend ? "ENVIAR" : "$_secondsRemaining s",
                  style: TextStyle(
                    color: _canResend ? Colors.cyanAccent : Colors.white38, 
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // LÓGICA DE VALIDACIÓN PARA QUE NO SE CONGELE
            if (_codeController.text == codigoGenerado && _codeController.text.isNotEmpty) {
              sourceView = currentView;
              _switchView('nueva_pass');
            } else {
              _showSnackBar("El código es incorrecto. Inténtalo de nuevo.", Colors.redAccent);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 65),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text("CONTINUAR", style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _switchView('login'), 
          child: const Text("Cancelar proceso", style: TextStyle(color: Colors.white24, fontSize: 12))
        ),
      ],
    );
  }

  Widget _interfaceNuevaPassword() {
    return Column(
      key: const ValueKey("nueva_pass"),
      children: [
        Text("CREAR CLAVE", style: GoogleFonts.orbitron(fontSize: 20, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 35),
        TextField(
          controller: _passController, 
          obscureText: true, 
          decoration: const InputDecoration(hintText: "Nueva Contraseña")
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmPassController, 
          obscureText: true, 
          decoration: const InputDecoration(hintText: "Confirmar Contraseña")
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            if (_passController.text == _confirmPassController.text && _passController.text.length >= 6) {
              _switchView('login');
              _showSnackBar("¡Perfil Vortex configurado! Ya puedes entrar.", Colors.green);
            } else {
              _showSnackBar("Las contraseñas no coinciden o son muy cortas.", Colors.orangeAccent);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 65),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text("GUARDAR Y FINALIZAR", style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
