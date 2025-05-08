import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharmacare/Screens/FichaMedicaScreen.dart';
import 'package:pharmacare/Screens/PerfilScreen.dart';
import 'package:pharmacare/Screens/chatSeguimiento.dart';
import 'package:pharmacare/Screens/Medicos.dart';
import 'package:pharmacare/Screens/FavoritosScreen.dart';
import 'package:pharmacare/Screens/citasUsuarios.dart';
import '../Widgets/common_widgets.dart';
import 'detallesMedicamentos.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> getMedicamentos() async {
    final snapshot = await FirebaseFirestore.instance.collection('Medicamento').get();
    final meds = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
    meds.shuffle(Random());
    return meds;
  }

  void _openDetalles(Map<String, dynamic> med) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallesMedicamentoScreen(medicamento: med),
      ),
    );
  }

  void _onSearchChanged(String text) {
    setState(() {
      _searchQuery = text.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar medicamentos',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filtro aún no implementado')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notificaciones')),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(152, 2, 56, 129)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Admin', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Mis citas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CitasUsuario()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritosScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categorías'),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Categorías')),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Ficha médica'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FichaMedicaScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración')),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text('Debes iniciar sesión para ver contenido'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: getMedicamentos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final meds = snapshot.data ?? [];

                final filtered = _searchQuery.isEmpty
                    ? meds
                    : meds.where((med) {
                        final nombre = (med['nombreMedicamento'] ?? med['nombre'] ?? '')
                            .toString()
                            .toLowerCase();
                        return nombre.startsWith(_searchQuery);
                      }).toList();

                if (_searchQuery.isNotEmpty) {
                  return filtered.isEmpty
                      ? Center(child: Text('No se encontró "$_searchQuery"'))
                      : ListView(
                          padding: const EdgeInsets.all(8),
                          children: [
                            _buildSection(title: 'Resultados', items: filtered),
                          ],
                        );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user.uid)
                      .collection('favoritos')
                      .snapshots(),
                  builder: (context, favSnap) {
                    if (favSnap.connectionState != ConnectionState.active) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final favIds = favSnap.data?.docs.map((d) => d.id).toList() ?? [];
                    final half = (meds.length / 2).ceil();
                    final descuento = meds.sublist(0, half);
                    final comunes = meds.sublist(half);
                    final favoritosMed = meds.where((med) => favIds.contains(med['id'])).toList();

                    final sections = <Widget>[];
                    sections.add(const ImageCarousel(
                      images: [
                        'image/Similares.jpg',
                        'image/FarmaAhorro.jpg',
                        'image/SuperFarma.jpg',
                      ],
                    ));
                    if (favoritosMed.isNotEmpty) {
                      sections.add(_buildSection(title: 'Tus favoritos', items: favoritosMed));
                    }
                    sections.add(_buildSection(title: 'En descuento', items: descuento));
                    sections.add(_buildSection(title: 'Comunes', items: comunes));

                    return ListView(padding: const EdgeInsets.all(8), children: sections);
                  },
                );
              },
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == _selectedIndex) return;
          setState(() => _selectedIndex = i);

          Widget destino;
          switch (i) {
            case 0:
              destino = const PantallaPrincipal();
              break;
            case 1:
              destino = const Medicos();
              break;
            case 2:
              destino = const ChatSeguimiento();
              break;
            default:
              return;
          }

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destino));
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      width: 350,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final med = items[index];
              return GestureDetector(
                onTap: () => _openDetalles(med),
                child: ProductRectangleWithText(
                  imageUrl: med['imagenUrl'] ?? '',
                  productName: med['nombreMedicamento'] ?? med['nombre'] ?? '',
                  description: med['descripcion'] ?? '',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
