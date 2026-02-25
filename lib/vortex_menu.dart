import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VortexTVInterface extends StatefulWidget {
  const VortexTVInterface({super.key});

  @override
  State<VortexTVInterface> createState() => _VortexTVInterfaceState();
}

class _VortexTVInterfaceState extends State<VortexTVInterface> {
  // VARIABLES DE ESTADO (Para que la interfaz reaccione)
  bool estaCargando = true; // Cambia a 'false' para ver el menú normal
  double velocidadKB = 623.7;
  int _selectedSidebarIndex = 0;

  final List<Map<String, dynamic>> _sidebarMenu = [
    {"icon": Icons.tv, "label": "TV"},
    {"icon": Icons.star, "label": "DESTACADOS"},
    {"icon": Icons.movie, "label": "PELÍCULAS"},
    {"icon": Icons.live_tv, "label": "SERIES"},
    {"icon": Icons.child_care, "label": "KIDS"},
    {"icon": Icons.local_fire_department, "label": "ANIME"},
    {"icon": Icons.explore, "label": "EXPLORAR"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CAPA DE FONDO OSCURO
          _buildBackground(),

          // 2. INTERFAZ PRINCIPAL
          Row(
            children: [
              _buildSidebar(),      // Menú izquierdo
              _buildChannelList(),  // Lista de canales a la derecha de la barra
              Expanded(
                child: Column(
                  children: [
                    _buildTopToolbar(), // Lupa, Wifi, Hora, etc.
                    Expanded(
                      child: estaCargando 
                        ? _buildLoadingScreen() // Muestra el círculo si carga
                        : const Center(child: Icon(Icons.play_arrow, size: 100, color: Colors.white24)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. BOTONES INFERIORES (Cuadrito, Estrella, Lupa)
          _buildBottomActions(),
        ],
      ),
    );
  }

  // --- COMPONENTES DE LA INTERFAZ ---

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF050505),
    );
  }

  Widget _buildTopToolbar() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _toolIcon(Icons.search),
          _toolIcon(Icons.tune),
          _toolIcon(Icons.history),
          _toolIcon(Icons.account_circle),
          _toolIcon(Icons.notifications),
          _toolIcon(Icons.wifi),
          const SizedBox(width: 15),
          Text("00:45", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(icon, color: Colors.white70, size: 24),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 100,
      color: Colors.black,
      child: Column(
        children: List.generate(_sidebarMenu.length, (index) {
          bool isSelected = _selectedSidebarIndex == index;
          return Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
              border: Border(left: BorderSide(color: isSelected ? Colors.blueAccent : Colors.transparent, width: 4)),
            ),
            child: Icon(_sidebarMenu[index]['icon'], color: isSelected ? Colors.white : Colors.white24, size: 30),
          );
        }),
      ),
    );
  }

  Widget _buildChannelList() {
    return Container(
      width: 200,
      color: Colors.white.withOpacity(0.01),
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
          child: const Text("CANAL EJEMPLO", style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 5),
          const SizedBox(height: 20),
          Text("${velocidadKB}KB/S", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 40,
      left: 120,
      child: Row(
        children: [
          _bottomIcon(Icons.apps),
          const SizedBox(width: 25),
          _bottomIcon(Icons.change_history),
          const SizedBox(width: 25),
          _bottomIcon(Icons.search),
        ],
      ),
    );
  }

  Widget _bottomIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white10),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
