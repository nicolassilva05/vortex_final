import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VortexTVInterface extends StatefulWidget {
  const VortexTVInterface({super.key});

  @override
  State<VortexTVInterface> createState() => _VortexTVInterfaceState();
}

class _VortexTVInterfaceState extends State<VortexTVInterface> {
  int _selectedCategory = 0; // TV, Películas, etc.
  int _selectedChannel = 0;

  final List<Map<String, dynamic>> _categories = [
    {"icon": Icons.tv, "label": "TV"},
    {"icon": Icons.star, "label": "DESTACADOS"},
    {"icon": Icons.movie, "label": "PELÍCULAS"},
    {"icon": Icons.live_tv, "label": "SERIES"},
    {"icon": Icons.child_care, "label": "KIDS"},
    {"icon": Icons.local_fire_department, "label": "ANIME"},
    {"icon": Icons.explore, "label": "EXPLORAR"},
  ];

  final List<String> _channels = ["ECDF", "ECDF FHD", "NBA Eventos", "A3S", "A&E HD", "A&E FHD"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CAPA 1: FONDO (BANNER / VIDEO)
          _buildBackground(),

          // CAPA 2: INTERFAZ DE NAVEGACIÓN
          Row(
            children: [
              _buildSidebar(),      // Menú izquierdo
              _buildChannelList(),  // Lista de canales dinámica
              Expanded(
                child: Column(
                  children: [
                    _buildTopToolbar(), // Buscador, Filtro, Perfil, etc.
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),

          // CAPA 3: BOTONES DE ACCIÓN INFERIORES
          _buildBottomActions(),
        ],
      ),
    );
  }

  // --- WIDGETS DE LA INTERFAZ ---

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.black, Colors.black.withOpacity(0.5), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildTopToolbar() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _toolIcon(Icons.search),           // Lupa
          _toolIcon(Icons.filter_list),      // Filtro
          _toolIcon(Icons.history),          // Historial
          _toolIcon(Icons.account_circle),   // Perfil
          _toolIcon(Icons.notifications),    // Campana
          _toolIcon(Icons.wifi),             // Wi-Fi
          const SizedBox(width: 15),
          Text("00:45", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon) {
    return Focus(
      child: Builder(builder: (context) {
        bool focused = Focus.of(context).hasFocus;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(icon, color: focused ? Colors.cyanAccent : Colors.white70, size: 24),
        );
      }),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 90,
      color: Colors.black,
      child: Column(
        children: List.generate(_categories.length, (index) {
          return Focus(
            onFocusChange: (f) if (f) setState(() => _selectedCategory = index),
            child: Builder(builder: (context) {
              bool focused = Focus.of(context).hasFocus;
              return Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: focused ? Colors.blueAccent : Colors.transparent, width: 4)),
                  color: focused ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
                ),
                child: Icon(_categories[index]['icon'], color: focused ? Colors.white : Colors.white38, size: 30),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildChannelList() {
    return Container(
      width: 200,
      color: Colors.white.withOpacity(0.02),
      child: ListView.builder(
        itemCount: _channels.length,
        itemBuilder: (context, index) {
          return Focus(
            onFocusChange: (f) if (f) setState(() => _selectedChannel = index),
            child: Builder(builder: (context) {
              bool focused = Focus.of(context).hasFocus;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: focused ? Colors.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_channels[index], style: const TextStyle(color: Colors.white, fontSize: 14)),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 40,
      left: 110,
      child: Row(
        children: [
          _bottomIcon(Icons.apps),           // Cuadradito
          const SizedBox(width: 25),
          _bottomIcon(Icons.change_history), // Triángulo (Favoritos)
          const SizedBox(width: 25),
          _bottomIcon(Icons.search),         // Lupita abajo
        ],
      ),
    );
  }

  Widget _bottomIcon(IconData icon) {
    return Focus(
      child: Builder(builder: (context) {
        bool focused = Focus.of(context).hasFocus;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: focused ? Colors.cyanAccent : Colors.white10,
          ),
          child: Icon(icon, color: focused ? Colors.black : Colors.white, size: 22),
        );
      }),
    );
  }
}
