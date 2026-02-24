import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math'; // Necesario para el ID aleatorio
import 'package:http/http.dart' as http;

void main() {
  runApp(const VertoxApp());
}

// =============================================================
// MOTOR DE CONEXIONES EXTERNAS (SQLITE CLOUD & EMAILJS)
// =============================================================
class VertoxBridge {
  static const String sqliteHost = "neuiydkddk.sqlite.cloud"; 
  static const String sqliteApiKey = "p4XiJ0RRCVtdyJSEPgcBbQPBePiSFawovRsuvPEKbOc";

  static const String serviceGmail = "service_w4zcrli";
  static const String serviceOutlook = "service_uagbfvc";
  static const String emailTemplateId = "template_rbyu42h"; 
  static const String emailPublicKey = "PRoX1Ao5_SrB4sncc";

  // Función de envío inteligente con Failover
  static Future<bool> sendEmailOTP(String userEmail, String otpCode) async {
    bool success = await _executeEmailJS(serviceGmail, userEmail, otpCode);
    if (!success) {
      debugPrint("GMAIL SERVICE DOWN - SWITCHING TO OUTLOOK FAILOVER");
      success = await _executeEmailJS(serviceOutlook, userEmail, otpCode);
    }
    return success;
  }

  static Future<bool> _executeEmailJS(String serviceId, String userEmail, String otpCode) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': emailTemplateId,
          'user_id': emailPublicKey,
          'template_params': {
            'user_email': userEmail,
            'codigo_vortex': otpCode, // CAMBIADO: Antes decía 'code', ahora coincide con tu EmailJS
            'reply_to': 'nicolassilvaharry2005@gmail.com',
          },
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Sincronización con límite de 2 dispositivos
  static Future<bool> syncNewUser(String email, String pass, String uniqueID) async {
    // Simulamos la inserción en SQLITE CLOUD guardando el ID y el límite de 2
    debugPrint("SQLITE CLOUD: INSERT INTO USERS (email, pass, vertox_id, dev_limit) VALUES ('$email', '$pass', '$uniqueID', 2)");
    await Future.delayed(const Duration(seconds: 2)); 
    return true; 
  }

  static Future<Map<String, dynamic>?> dbLogin(String email, String pass) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      "name": email.split('@')[0], 
      "email": email, 
      "role": "ADMIN",
      "avatar": "https://cdn-icons-png.flaticon.com/512/4712/4712139.png"
    };
  }
}

class VertoxApp extends StatefulWidget {
  const VertoxApp({super.key});

  @override
  State<VertoxApp> createState() => _VertoxAppState();
}

class _VertoxAppState extends State<VertoxApp> {
  String currentSector = 'INTRO'; 
  bool isLoggedIn = false;
  Map<String, dynamic>? currentUser;
  String savedPassword = ""; 

  final List<Map<String, String>> avatarGallery = [
    {"name": "CYBER-BOT", "url": "https://cdn-icons-png.flaticon.com/512/4712/4712139.png"},
    {"name": "LORD VAMP", "url": "https://cdn-icons-png.flaticon.com/512/3815/3815525.png"},
    {"name": "THE MUMMY", "url": "https://cdn-icons-png.flaticon.com/512/3815/3815555.png"},
    {"name": "OFFICER", "url": "https://cdn-icons-png.flaticon.com/512/3011/3011285.png"},
  ];

  void changeSector(String sector, {Map<String, dynamic>? user, String? pass}) {
    setState(() {
      currentSector = sector;
      if (user != null) {
        currentUser = user;
        isLoggedIn = true;
        if (pass != null) savedPassword = pass;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vertox Premium OS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF010101),
        primaryColor: Colors.cyanAccent,
      ),
      home: _routeManager(),
    );
  }

  Widget _routeManager() {
    if (isLoggedIn && (currentSector == 'LOGIN' || currentSector == 'REGISTER' || currentSector == 'FORGOT')) {
      return VertoxProfiles(
        user: currentUser, 
        gallery: avatarGallery,
        onSelect: () => changeSector('HOME'),
      );
    }

    switch (currentSector) {
      case 'INTRO': return VertoxIntro(onFinished: () => changeSector('LOGIN'));
      case 'LOGIN': return VertoxLogin(
          onRegister: () => changeSector('REGISTER'),
          onForgot: () => changeSector('FORGOT'),
          onSuccess: (user, p) => changeSector('PROFILES', user: user, pass: p),
        );
      case 'REGISTER': return VertoxRegister(onBack: () => changeSector('LOGIN'));
      case 'FORGOT': return VertoxForgotPass(onBack: () => changeSector('LOGIN'));
      case 'PROFILES': return VertoxProfiles(
          user: currentUser, 
          gallery: avatarGallery,
          onSelect: () => changeSector('HOME'),
        );
      case 'HOME': return VertoxHomeScreen(
          savedPassword: savedPassword,
          onLogout: () {
            setState(() { isLoggedIn = false; savedPassword = ""; });
            changeSector('LOGIN');
          },
        );
      default: return VertoxIntro(onFinished: () => changeSector('LOGIN'));
    }
  }
}

// ==========================================
// VUI: VISUAL USER INTERFACE
// ==========================================
class VUI {
  static void showStatus(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.warning_amber_rounded : Icons.verified_rounded, color: Colors.white),
            const SizedBox(width: 15),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1))),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.cyanAccent.withOpacity(0.7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(25),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Widget decorativeBackground(Widget child) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.3,
          colors: [Color(0xFF002222), Color(0xFF010101)],
        ),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.05,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 15),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.cyanAccent.withOpacity(0.1))),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  static Widget backButton(VoidCallback onTap) {
    return Positioned(
      top: 40,
      left: 30,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new, color: Colors.cyanAccent, size: 14),
              SizedBox(width: 10),
              Text("VOLVER", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget input({
    required String hint, 
    required IconData icon, 
    bool isPass = false, 
    TextEditingController? ctrl, 
    bool enabled = true,
    Function(String)? onChange,
    Widget? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 500,
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        enabled: enabled,
        onChanged: onChange,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: Icon(icon, color: enabled ? Colors.cyanAccent : Colors.white12),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.cyanAccent, width: 2)),
        ),
      ),
    );
  }

  static Widget mainButton({required String text, required VoidCallback? onPressed, bool isLoading = false}) {
    return Container(
      width: 500,
      height: 75,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 15,
          shadowColor: Colors.cyanAccent.withOpacity(0.4),
        ),
        child: isLoading 
          ? const CircularProgressIndicator(color: Colors.black)
          : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4)),
      ),
    );
  }
}

// ==========================================
// PANTALLAS DE FLUJO
// ==========================================

class VertoxIntro extends StatelessWidget {
  final VoidCallback onFinished;
  const VertoxIntro({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VUI.decorativeBackground(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cyclone, size: 160, color: Colors.cyanAccent),
              const SizedBox(height: 20),
              const Text("VERTOX", style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, letterSpacing: 30, color: Colors.cyanAccent)),
              const Text("PREMIUM OS V.2.0", style: TextStyle(fontSize: 12, letterSpacing: 10, color: Colors.white24)),
              const SizedBox(height: 100),
              VUI.mainButton(text: "INICIALIZAR", onPressed: onFinished),
            ],
          ),
        ),
      ),
    );
  }
}

class VertoxLogin extends StatefulWidget {
  final VoidCallback onRegister, onForgot;
  final Function(Map<String, dynamic>, String) onSuccess;
  const VertoxLogin({super.key, required this.onRegister, required this.onForgot, required this.onSuccess});

  @override State<VertoxLogin> createState() => _VertoxLoginState();
}

class _VertoxLoginState extends State<VertoxLogin> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VUI.decorativeBackground(
        Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("SISTEMA DE ACCESO", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 5)),
                Container(height: 2, width: 150, color: Colors.cyanAccent, margin: const EdgeInsets.symmetric(vertical: 30)),
                VUI.input(hint: "ID de Acceso / Email", icon: Icons.alternate_email, ctrl: userCtrl),
                VUI.input(hint: "Contraseña", icon: Icons.lock_open, isPass: true, ctrl: passCtrl),
                const SizedBox(height: 20),
                VUI.mainButton(
                  text: "ENTRAR AL SISTEMA", 
                  isLoading: loading,
                  onPressed: () async {
                    if (userCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
                      setState(() => loading = true);
                      var user = await VertoxBridge.dbLogin(userCtrl.text, passCtrl.text);
                      setState(() => loading = false);
                      widget.onSuccess(user!, passCtrl.text);
                    } else {
                      VUI.showStatus(context, "Por favor complete las credenciales", isError: true);
                    }
                  }
                ),
                TextButton(onPressed: widget.onRegister, child: const Text("SOLICITAR NUEVA IDENTIDAD", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 1))),
                TextButton(onPressed: widget.onForgot, child: const Text("¿OLVIDASTE TU TOKEN?", style: TextStyle(color: Colors.white24))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VertoxRegister extends StatefulWidget {
  final VoidCallback onBack;
  const VertoxRegister({super.key, required this.onBack});
  @override State<VertoxRegister> createState() => _VertoxRegisterState();
}

class _VertoxRegisterState extends State<VertoxRegister> {
  final TextEditingController mail = TextEditingController();
  final TextEditingController code = TextEditingController();
  final TextEditingController p1 = TextEditingController();
  final TextEditingController p2 = TextEditingController();
  
  bool isVerified = false;
  int secondsRemaining = 0;
  Timer? timer;
  bool isSending = false;
  String generatedCode = (Random().nextInt(900000) + 100000).toString(); // Código OTP dinámico

  void startTimer() {
    setState(() => secondsRemaining = 60);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining > 0) { setState(() => secondsRemaining--); } else { t.cancel(); }
    });
  }

  void _showSuccessIDDialog(String finalID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Colors.cyanAccent, width: 2)),
        title: const Text("REGISTRO EXITOSO", textAlign: TextAlign.center, style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 3)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            const Text("Su Identidad ha sido creada en la nube.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Text("SU ID ÚNICO DE ACCESO:", style: TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Text(finalID, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.cyanAccent)),
            ),
            const SizedBox(height: 25),
            const Text("⚠️ RESTRICCIÓN IMPORTANTE:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            const Text("Este ID es válido para máximo 2 dispositivos.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () { Navigator.pop(context); widget.onBack(); },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text("ENTENDIDO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool match = p1.text == p2.text && p1.text.isNotEmpty;
    return Scaffold(
      body: VUI.decorativeBackground(
        Stack(
          children: [
            VUI.backButton(widget.onBack),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("CREAR IDENTIDAD CLOUD", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 5)),
                    const SizedBox(height: 40),
                    VUI.input(hint: "Correo Corporativo", icon: Icons.email, ctrl: mail, enabled: !isVerified),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 380, child: VUI.input(hint: "Código OTP", icon: Icons.verified_user, ctrl: code, enabled: !isVerified)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: (secondsRemaining == 0 && !isVerified && !isSending) ? () async {
                            if(!mail.text.contains('@')) { VUI.showStatus(context, "Email inválido", isError: true); return; }
                            setState(() => isSending = true);
                            bool sent = await VertoxBridge.sendEmailOTP(mail.text, generatedCode);
                            setState(() => isSending = false);
                            if(sent) {
                              startTimer();
                              VUI.showStatus(context, "CÓDIGO ENVIADO CON ÉXITO");
                            } else {
                              VUI.showStatus(context, "FALLO CRÍTICO EN SERVICIOS DE CORREO", isError: true);
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent, 
                            disabledBackgroundColor: Colors.white12,
                            minimumSize: const Size(110, 75), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                          ),
                          child: isSending 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : Text(secondsRemaining > 0 ? "$secondsRemaining s" : "ENVIAR", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (!isVerified) VUI.mainButton(text: "VERIFICAR IDENTIDAD", onPressed: () {
                      if (code.text == generatedCode) {
                        setState(() => isVerified = true);
                        VUI.showStatus(context, "ACCESO CONCEDIDO - COMPLETE SU PASSWORD");
                      } else {
                        VUI.showStatus(context, "ERROR: CÓDIGO INVÁLIDO", isError: true);
                      }
                    }),
                    if (isVerified) ...[
                      VUI.input(hint: "Contraseña", icon: Icons.lock, isPass: true, ctrl: p1, onChange: (_) => setState(() {}), suffix: Icon(match ? Icons.check_circle : Icons.error, color: match ? Colors.greenAccent : Colors.redAccent)),
                      VUI.input(hint: "Confirmar", icon: Icons.lock_reset, isPass: true, ctrl: p2, onChange: (_) => setState(() {}), suffix: Icon(match ? Icons.check_circle : Icons.error, color: match ? Colors.greenAccent : Colors.redAccent)),
                      VUI.mainButton(text: "FINALIZAR REGISTRO", onPressed: match ? () async { 
                        VUI.showStatus(context, "REGISTRANDO EN SQLITE CLOUD...");
                        
                        // GENERACIÓN DEL ID DE 6 DÍGITOS
                        String miID = (Random().nextInt(900000) + 100000).toString();
                        
                        await VertoxBridge.syncNewUser(mail.text, p1.text, miID);
                        _showSuccessIDDialog(miID);
                      } : null),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VertoxForgotPass extends StatefulWidget {
  final VoidCallback onBack;
  const VertoxForgotPass({super.key, required this.onBack});
  @override State<VertoxForgotPass> createState() => _VertoxForgotPassState();
}

class _VertoxForgotPassState extends State<VertoxForgotPass> {
  final TextEditingController mail = TextEditingController();
  final TextEditingController code = TextEditingController();
  final TextEditingController p1 = TextEditingController();
  final TextEditingController p2 = TextEditingController();
  
  bool isVerified = false;
  int secondsRemaining = 0;
  Timer? timer;
  bool isSending = false;
  String generatedCode = "888999";

  void startTimer() {
    setState(() => secondsRemaining = 60);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining > 0) { setState(() => secondsRemaining--); } else { t.cancel(); }
    });
  }

  @override void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool match = p1.text == p2.text && p1.text.isNotEmpty;
    return Scaffold(
      body: VUI.decorativeBackground(
        Stack(
          children: [
            VUI.backButton(widget.onBack),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("RESETEAR TOKEN", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    const SizedBox(height: 40),
                    VUI.input(hint: "Email de Recuperación", icon: Icons.mail_outline, ctrl: mail, enabled: !isVerified),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 380, child: VUI.input(hint: "Código de Seguridad", icon: Icons.security, ctrl: code, enabled: !isVerified)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: (secondsRemaining == 0 && !isVerified && !isSending) ? () async {
                            if(mail.text.isEmpty) { VUI.showStatus(context, "Ingrese su email", isError: true); return; }
                            setState(() => isSending = true);
                            bool sent = await VertoxBridge.sendEmailOTP(mail.text, generatedCode);
                            setState(() => isSending = false);
                            if(sent) {
                              startTimer();
                              VUI.showStatus(context, "TOKEN ENVIADO CON ÉXITO");
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent, 
                            disabledBackgroundColor: Colors.white12,
                            minimumSize: const Size(110, 75), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                          ),
                          child: isSending 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : Text(secondsRemaining > 0 ? "$secondsRemaining s" : "ENVIAR", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (!isVerified) VUI.mainButton(text: "VALIDAR TOKEN", onPressed: () {
                      if (code.text == generatedCode) {
                        setState(() => isVerified = true);
                        VUI.showStatus(context, "TOKEN VALIDADO CORRECTAMENTE");
                      } else {
                        VUI.showStatus(context, "ERROR: TOKEN INVÁLIDO", isError: true);
                      }
                    }),
                    if (isVerified) ...[
                      VUI.input(hint: "Nueva Password", icon: Icons.vpn_key, isPass: true, ctrl: p1, onChange: (_) => setState(() {}), suffix: Icon(match ? Icons.check : Icons.close, color: match ? Colors.green : Colors.red)),
                      VUI.input(hint: "Repetir Password", icon: Icons.lock_reset, isPass: true, ctrl: p2, onChange: (_) => setState(() {}), suffix: Icon(match ? Icons.check : Icons.close, color: match ? Colors.green : Colors.red)),
                      VUI.mainButton(text: "ACTUALIZAR TOKEN", onPressed: match ? () { VUI.showStatus(context, "TOKEN ACTUALIZADO EXITOSAMENTE"); widget.onBack(); } : null),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VertoxProfiles extends StatefulWidget {
  final Map<String, dynamic>? user;
  final List<Map<String, String>> gallery;
  final VoidCallback onSelect;
  const VertoxProfiles({super.key, this.user, required this.gallery, required this.onSelect});

  @override State<VertoxProfiles> createState() => _VertoxProfilesState();
}

class _VertoxProfilesState extends State<VertoxProfiles> {
  int selectedIndex = 0;
  bool isEditing = false;
  late TextEditingController nameCtrl;

  @override void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user?['name'] ?? "Usuario");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VUI.decorativeBackground(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("¿QUIÉN OPERA EL SISTEMA?", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: 10)),
              const SizedBox(height: 70),
              if (!isEditing) ...[
                GestureDetector(
                  onTap: widget.onSelect,
                  child: Column(
                    children: [
                      Container(
                        width: 260, height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyanAccent, width: 6),
                          image: DecorationImage(image: NetworkImage(widget.gallery[selectedIndex]["url"]!), fit: BoxFit.cover),
                          boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 60)],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(nameCtrl.text.toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5)),
                      const SizedBox(height: 10),
                      TextButton.icon(onPressed: () => setState(() => isEditing = true), icon: const Icon(Icons.edit, color: Colors.cyanAccent), label: const Text("CAMBIAR PERFIL", style: TextStyle(color: Colors.cyanAccent))),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.gallery.length, (i) => GestureDetector(
                    onTap: () => setState(() => selectedIndex = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selectedIndex == i ? Colors.cyanAccent : Colors.transparent, width: 4)),
                      child: CircleAvatar(radius: 55, backgroundImage: NetworkImage(widget.gallery[i]["url"]!)),
                    ),
                  )),
                ),
                const SizedBox(height: 40),
                VUI.input(hint: "Alias de Operador", icon: Icons.face, ctrl: nameCtrl),
                VUI.mainButton(text: "GUARDAR CAMBIOS", onPressed: () => setState(() => isEditing = false)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class VertoxHomeScreen extends StatefulWidget {
  final String savedPassword;
  final VoidCallback onLogout;
  const VertoxHomeScreen({super.key, required this.savedPassword, required this.onLogout});

  @override State<VertoxHomeScreen> createState() => _VertoxHomeScreenState();
}

class _VertoxHomeScreenState extends State<VertoxHomeScreen> {
  final TextEditingController checkPass = TextEditingController();

  void _triggerLogoutProcedure() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Colors.redAccent, width: 1)),
        title: const Text("SEGURIDAD DE SALIDA", style: TextStyle(color: Colors.redAccent, letterSpacing: 2, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Valide su identidad para cerrar la sesión activa.", textAlign: TextAlign.center),
            const SizedBox(height: 25),
            VUI.input(hint: "Password de Seguridad", icon: Icons.lock_person, isPass: true, ctrl: checkPass),
          ],
        ),
        actions: [
          TextButton(onPressed: () { checkPass.clear(); Navigator.pop(context); }, child: const Text("CANCELAR", style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              if (checkPass.text == widget.savedPassword) {
                Navigator.pop(context);
                widget.onLogout();
                VUI.showStatus(context, "SISTEMA DESCONECTADO");
              } else {
                VUI.showStatus(context, "ERROR: CONTRASEÑA INCORRECTA", isError: true);
              }
            },
            child: const Text("CONFIRMAR SALIDA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 320,
            decoration: const BoxDecoration(color: Color(0xFF050505), border: Border(right: BorderSide(color: Colors.white10))),
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.cyclone, color: Colors.cyanAccent, size: 60),
                const Text("VERTOX", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.cyanAccent, letterSpacing: 5)),
                const SizedBox(height: 80),
                _navTile(Icons.tv, "CANALES LIVE", active: true),
                _navTile(Icons.movie_filter, "CINE HUB"),
                _navTile(Icons.storage, "SQLITE CLOUD MANAGER"),
                _navTile(Icons.person_pin, "MI IDENTIDAD"),
                const Spacer(),
                _navTile(Icons.power_settings_new, "DESCONECTAR", color: Colors.redAccent, onTap: _triggerLogoutProcedure),
                const SizedBox(height: 50),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal, size: 100, color: Colors.white10),
                  SizedBox(height: 20),
                  Text("SISTEMA VERTOX CARGADO\nESPERANDO COMANDOS", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, letterSpacing: 10, color: Colors.white12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(IconData i, String t, {bool active = false, Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(i, color: active ? Colors.cyanAccent : (color ?? Colors.white24), size: 28),
      title: Text(t, style: TextStyle(color: active ? Colors.white : (color ?? Colors.white24), letterSpacing: 2, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
    );
  }
}
