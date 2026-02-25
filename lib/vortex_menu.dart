import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VortexTVMenu extends StatefulWidget {
  const VortexTVMenu({super.key});

  @override
  State<VortexTVMenu> createState() => _VortexTVMenuState();
}

class _VortexTVMenuState extends State<VortexTVMenu> {
  int _selectedCategory = 0; // TV, Películas, etc.
  int _selectedChannel = 0;  // Navegación en la lista de canales desplegada

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.tv, "label": "TV"},
    {"icon": Icons.star, "label": "DESTACADOS"},
    {"icon": Icons.movie, "label": "PELÍCULA"},
    {"icon": Icons.live_tv, "label": "SERIES"},
    {"icon": Icons.child_care, "label": "KIDS"},
    {"icon": Icons.local_fire_department, "label": "ANIME"},
    {"icon": Icons.explore, "label": "EXPLORAR"},
  ];

  // Canales que aparecen al estar en el sector TV (como en tu foto)
  final List<String> quickChannels = ["ECDF", "ECDF FHD", "NBA Eventos", "A3S", "A&E HD", "A&E FHD"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          Row(
            children: [
              // 1. BARRA LATERAL PRINCIPAL
              _buildSidebar(),

              // 2. LISTA DE CANALES DESPLEGADA (Sector TV)
              _buildQuickChannelList(),

              // 3. CONTENIDO PRINCIPAL
              Expanded(
                child: Column(
                  children: [
                    _buildTopToolbar(), // Lupa, Filtro, Historial, etc.
                    Expanded(child: _buildMainView()),
                  ],
                ),
              ),
            ],
          ),
          // Botones flotantes inferiores (Favoritos, Buscar abajo)
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  // --- COMPONENTES DEL MENÚ ---

  Widget _buildSidebar() {
    return Container(
      width: 80,
      color: Colors.black,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == index;
          return Focus(
            onFocusChange: (f) if (f) setState(() => _selectedCategory = index),
            child: Container(
              height: 70,
              color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
              child: Icon(categories[index]['icon'], color: isSelected ? Colors.white : Colors.white38),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickChannelList() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: ListView.builder(
        itemCount: quickChannels.length,
        itemBuilder: (context, index) {
          return Focus(
            onFocusChange: (f) if (f) setState(() => _selectedChannel = index),
            child: Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: _selectedChannel == index ? Colors.blueAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(quickChannels[index], style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopToolbar() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
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
          Text("00:45", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }

  Widget _buildMainView() {
    return Center(
      child: Text("Sector: ${categories[_selectedCategory]['label']}", 
      style: TextStyle(color: Colors.white24, fontSize: 30)),
    );
  }

  Widget _buildBottomActionButtons() {
    return Positioned(
      bottom: 30,
      left: 100,
      child: Row(
        children: [
          _actionBtn(Icons.apps),           // Cuadradito (Abre todo)
          const SizedBox(width: 20),
          _actionBtn(Icons.change_history), // Triángulo (Favoritos)
          const SizedBox(width: 20),
          _actionBtn(Icons.search),         // Lupita inferior
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
