import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Borramos el "void main" porque ahora manda el main.dart principal

class VortexTVInterface extends StatefulWidget {
  final Map<String, dynamic>? user; // Recibe el usuario del login
  final VoidCallback onLogout;      // Recibe la función para salir

  const VortexTVInterface({super.key, this.user, required this.onLogout});

  @override
  State<VortexTVInterface> createState() => _VortexTVInterfaceState();
}

class VortexTVInterface extends StatefulWidget {
  const VortexTVInterface({super.key});

  @override
  State<VortexTVInterface> createState() => _VortexTVInterfaceState();
}

class _VortexTVInterfaceState extends State<VortexTVInterface> {
  // --- ESTADOS GLOBALES ---
  bool estaCargando = true;
  bool modoPantallaCompleta = false;
  bool menuEnFoco = false; 
  int indexMenu = 0;
  String? seccionActual;
  
  // Control de canales
  int canalInicial = 1;
  String elementoEnFoco = ""; 

  bool canalBloqueado = false;
  bool esFavorito = false;

  // --- LÓGICA DE INTERNET (WIFI) ---
  // Estos valores son los que cambiarán según la conexión del TV
  bool estaConectado = true; 
  int nivelSenal = 3; // 0, 1, 2, 3 (barras de señal)

  // Opciones del Menú Lateral
  final List<Map<String, dynamic>> secciones = [
    {'icon': Icons.tv, 'label': 'TV'},
    {'icon': Icons.thumb_up_off_alt, 'label': 'DESTACADOS'},
    {'icon': Icons.movie_filter, 'label': 'PELICULA'},
    {'icon': Icons.live_tv, 'label': 'SERIES'},
    {'icon': Icons.child_care, 'label': 'KIDS'},
    {'icon': Icons.face, 'label': 'ANIME'},
  ];

  @override
  void initState() {
    super.initState();
    // Simulación de carga de inicio
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => estaCargando = false);
    });
  }

  // Método para navegar entre los canales de la grilla
  void _cambiarCanales(bool subir) {
    setState(() {
      if (subir && canalInicial > 1) {
        canalInicial -= 2;
      } else if (!subir && canalInicial < 94) {
        canalInicial += 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si entramos en una sección (Ej: PELICULAS), mostramos la interfaz vacía configurada
    if (seccionActual != null) {
      return _buildEmptySection();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020205), // Negro azulado premium
      body: Stack(
        children: [
          // 1. EL LOGO DE VORTEX TV (Se oculta en fullscreen)
          if (!modoPantallaCompleta)
            Positioned(
              top: 45,
              left: 115,
              child: _buildPremiumLogo(),
            ),

          // 2. EL REPRODUCTOR DE VIDEO PRINCIPAL
          _buildMainVideoArea(),

          // 3. LA INTERFAZ DE USUARIO (Controles y Menús)
          if (!modoPantallaCompleta) ...[
            _buildFullTopToolbar(),       
            _buildSidebarMenu(), 
            _buildChannelGrid(),           
            _buildInteractiveBottomBar(),  
          ],

          // 4. OVERLAY DE PANTALLA COMPLETA
          if (modoPantallaCompleta) _buildFullScreenOverlay(),
        ],
      ),
    );
  }

  // --- WIDGET DE ICONO DE WIFI SEGÚN ESTADO ---
  Widget _buildWifiIcon() {
    // Si no hay internet: Gris con punto rojo al costado
    if (!estaConectado) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: Colors.grey, size: 26),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red, 
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    }

    // Si hay internet: Blanco con barras dinámicas
    IconData iconData;
    switch (nivelSenal) {
      case 0: iconData = Icons.network_wifi_1_bar; break;
      case 1: iconData = Icons.network_wifi_2_bar; break;
      case 2: iconData = Icons.network_wifi_3_bar; break;
      default: iconData = Icons.wifi;
    }
    return Icon(iconData, color: Colors.white, size: 26);
  }

  // --- DISEÑO DEL LOGO VORTEX ---
  Widget _buildPremiumLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "VORTEX",
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 15)
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "TV", 
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
              ),
            ),
          ],
        ),
        Container(
          height: 3,
          width: 140,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.cyanAccent, Colors.transparent]),
          ),
        )
      ],
    );
  }

  // --- PANTALLA DE SECCIÓN EN DESARROLLO ---
  Widget _buildEmptySection() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              seccionActual!.toUpperCase(), 
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 45, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            const Text("ESTÁ VACÍO POR EL MOMENTO", style: TextStyle(color: Colors.white24, fontSize: 18)),
            const SizedBox(height: 60),
            MouseRegion(
              onEnter: (_) => setState(() => elementoEnFoco = "volver"),
              onExit: (_) => setState(() => elementoEnFoco = ""),
              child: GestureDetector(
                onTap: () => setState(() => seccionActual = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  decoration: BoxDecoration(
                    color: elementoEnFoco == "volver" ? Colors.cyanAccent : Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "REGRESAR", 
                    style: TextStyle(
                      color: elementoEnFoco == "volver" ? Colors.black : Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 20
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ÁREA DE VIDEO (REPRODUCTOR) ---
  Widget _buildMainVideoArea() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      top: modoPantallaCompleta ? 0 : 130,
      bottom: modoPantallaCompleta ? 0 : 230,
      left: modoPantallaCompleta ? 0 : 115,
      right: modoPantallaCompleta ? 0 : 380,
      child: MouseRegion(
        onEnter: (_) => setState(() => elementoEnFoco = "video"),
        onExit: (_) => setState(() => elementoEnFoco = ""),
        child: GestureDetector(
          onTap: () => setState(() => modoPantallaCompleta = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF050505),
              borderRadius: BorderRadius.circular(modoPantallaCompleta ? 0 : 15),
              border: Border.all(
                color: (elementoEnFoco == "video" && !modoPantallaCompleta) ? Colors.blueAccent : Colors.white10,
                width: (elementoEnFoco == "video" && !modoPantallaCompleta) ? 4 : 1,
              ),
            ),
            child: estaCargando 
              ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
              : Stack(
                  children: [
                    const Center(child: Icon(Icons.play_circle_outline, color: Colors.white12, size: 100)),
                    // BARRA DE CARGA DEL VIDEO (Solución visual para PC/Web)
                    if (!modoPantallaCompleta)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 8)
                            ],
                          ),
                          child: const LinearProgressIndicator(
                            value: 0.4,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  // --- BARRA SUPERIOR (RELOJ, WIFI, PERFIL) ---
  Widget _buildFullTopToolbar() {
    return Positioned(
      top: 45, right: 60,
      child: Row(
        children: [
          _topIconButton(Icons.search, "BUSCAR"), const SizedBox(width: 25),
          _topIconButton(Icons.filter_list, "FILTROS"), const SizedBox(width: 25),
          _topIconButton(Icons.history, "HISTORIAL"), const SizedBox(width: 25),
          _topIconButton(Icons.person_outline, "PERFIL"), const SizedBox(width: 25),
          _topIconButton(Icons.notifications_none, "AVISOS"), const SizedBox(width: 25),
          _buildWifiIcon(), // ICONO WIFI DINÁMICO
          const SizedBox(width: 25),
          const Text("01:18", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _topIconButton(IconData icon, String label) {
    return MouseRegion(
      onEnter: (_) => setState(() => elementoEnFoco = label),
      onExit: (_) => setState(() => elementoEnFoco = ""),
      child: GestureDetector(
        onTap: () => setState(() => seccionActual = label),
        child: Icon(icon, color: elementoEnFoco == label ? Colors.cyanAccent : Colors.white70, size: 26),
      ),
    );
  }

  // --- MENÚ LATERAL DESPLEGABLE ---
  Widget _buildSidebarMenu() {
    return Positioned(
      left: 0, top: 130, bottom: 230,
      child: MouseRegion(
        onEnter: (_) => setState(() => menuEnFoco = true),
        onExit: (_) => setState(() => menuEnFoco = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: menuEnFoco ? 260 : 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(secciones.length, (i) {
              bool seleccionado = (indexMenu == i && menuEnFoco);
              return MouseRegion(
                onEnter: (_) => setState(() { indexMenu = i; menuEnFoco = true; }),
                child: GestureDetector(
                  onTap: () => setState(() => seccionActual = secciones[i]['label']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: seleccionado ? Colors.blueAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(secciones[i]['icon'], color: seleccionado ? Colors.black : Colors.white, size: 28),
                        if (menuEnFoco) ...[
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              secciones[i]['label'], 
                              style: TextStyle(
                                color: seleccionado ? Colors.black : Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 16
                              )
                            )
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // --- BOTONES INFERIORES ---
  Widget _buildInteractiveBottomBar() {
    return Positioned(
      bottom: 145, left: 130,
      child: Row(
        children: [
          _navBottomIcon(Icons.grid_view_rounded, "APPS"),
          const SizedBox(width: 45),
          _navBottomIcon(Icons.star_border, "FAVORITOS"),
          const SizedBox(width: 45),
          _navBottomIcon(Icons.search, "BUSCAR"),
        ],
      ),
    );
  }

  Widget _navBottomIcon(IconData icon, String label) {
    bool enFoco = elementoEnFoco == label;
    return MouseRegion(
      onEnter: (_) => setState(() => elementoEnFoco = label),
      onExit: (_) => setState(() => elementoEnFoco = ""),
      child: GestureDetector(
        onTap: () => setState(() => seccionActual = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: enFoco ? Colors.blueAccent : Colors.white10,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: enFoco ? Colors.black : Colors.white, size: 35),
        ),
      ),
    );
  }

  // --- LISTA DE CANALES DERECHA ---
  Widget _buildChannelGrid() {
    return Positioned(
      right: 35, top: 130, bottom: 230,
      child: Column(
        children: [
          _channelArrow(Icons.keyboard_arrow_up, true),
          const SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              width: 320,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 15, 
                  mainAxisSpacing: 15
                ),
                itemCount: 6,
                itemBuilder: (context, index) => _channelTile(canalInicial + index),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _channelArrow(Icons.keyboard_arrow_down, false),
        ],
      ),
    );
  }

  Widget _channelArrow(IconData icon, bool arriba) {
    String tag = arriba ? "up" : "down";
    return MouseRegion(
      onEnter: (_) => setState(() => elementoEnFoco = tag),
      onExit: (_) => setState(() => elementoEnFoco = ""),
      child: GestureDetector(
        onTap: () => _cambiarCanales(!arriba),
        child: Icon(icon, color: elementoEnFoco == tag ? Colors.cyanAccent : Colors.white24, size: 45),
      ),
    );
  }

  Widget _channelTile(int n) {
    String tag = "chan_$n";
    bool enfocado = elementoEnFoco == tag;
    return MouseRegion(
      onEnter: (_) => setState(() => elementoEnFoco = tag),
      onExit: (_) => setState(() => elementoEnFoco = ""),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: enfocado ? Colors.blueAccent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: enfocado ? Colors.white : Colors.transparent, width: 2),
        ),
        child: Center(
          child: Text(
            "$n", 
            style: TextStyle(color: enfocado ? Colors.black : Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
          )
        ),
      ),
    );
  }

  // --- DISEÑO DE CONTROLES FULLSCREEN ---
  Widget _buildFullScreenOverlay() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter, 
            end: Alignment.topCenter, 
            colors: [Colors.black, Colors.transparent]
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text("VORTEX LIVE", style: TextStyle(color: Colors.white60, fontSize: 18)),
                const SizedBox(width: 25),
                const Text("CANAL EN REPRODUCCIÓN HD", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 35), 
                  onPressed: () => setState(() => modoPantallaCompleta = false)
                ),
              ],
            ),
            const SizedBox(height: 15),
            // BARRA DE PROGRESO CORREGIDA
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 0.35, 
                backgroundColor: Colors.white10, 
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _fullBtn(Icons.favorite, esFavorito ? Colors.red : Colors.white, () => setState(() => esFavorito = !esFavorito), "fav"),
                _fullBtn(Icons.lock, canalBloqueado ? Colors.blueAccent : Colors.white, () => setState(() => canalBloqueado = !canalBloqueado), "lock"),
                _fullBtn(Icons.settings, Colors.white, () {}, "settings"),
                _fullBtn(Icons.power_settings_new, Colors.white, () => setState(() => modoPantallaCompleta = false), "off"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _fullBtn(IconData i, Color c, VoidCallback t, String tag) {
    bool f = elementoEnFoco == tag;
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: MouseRegion(
        onEnter: (_) => setState(() => elementoEnFoco = tag),
        onExit: (_) => setState(() => elementoEnFoco = ""),
        child: CircleAvatar(
          radius: 28, 
          backgroundColor: f ? Colors.blueAccent : Colors.white10, 
          child: IconButton(icon: Icon(i, color: f ? Colors.black : c, size: 28), onPressed: t)
        ),
      ),
    );
  }
}
