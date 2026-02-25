import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VortexTVMenu extends StatefulWidget {
  const VortexTVMenu({super.key});

  @override
  State<VortexTVMenu> createState() => _VortexTVMenuState();
}

class _VortexTVMenuState extends State<VortexTVMenu> {
  int _selectedIndex = 0; // Control de la barra lateral
  
  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.tv, "label": "TV"},
    {"icon": Icons.star, "label": "DESTACADOS"},
    {"icon": Icons.movie, "label": "PELICULA"},
    {"icon": Icons.live_tv, "label": "SERIES"},
    {"icon": Icons.child_care, "label": "KIDS"},
    {"icon": Icons.local_fire_department, "label": "ANIME"},
    {"icon": Icons.explore, "label": "EXPLORAR"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          // BARRA LATERAL (Inspirada en tu captura de Naruto)
          _buildSideNavigation(),
          
          // CONTENIDO DINÁMICO (Grilla de Posters)
          Expanded(
            child: _buildContentGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 100, // Estilo compacto para que resalte el contenido
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: const Border(right: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return Focus(
            onFocusChange: (focus) if (focus) setState(() => _selectedIndex = index),
            child: Builder(builder: (context) {
              bool isFocused = Focus.of(context).hasFocus;
              return Container(
                height: 80,
                color: isFocused ? Colors.blueAccent : Colors.transparent,
                child: Icon(
                  menuItems[index]['icon'],
                  color: isFocused ? Colors.white : Colors.white38,
                  size: 30,
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildContentGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 posters por fila como en tu imagen
        childAspectRatio: 1.8, // Formato apaisado de TV
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => _buildMediaPoster(index),
    );
  }

  Widget _buildMediaPoster(int index) {
    return Focus(
      child: Builder(builder: (context) {
        bool hasFocus = Focus.of(context).hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasFocus ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: hasFocus ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 15)] : [],
          ),
          child: Center(
            child: Icon(Icons.play_circle_outline, color: hasFocus ? Colors.white : Colors.white24, size: 40),
          ),
        );
      }),
    );
  }
}
