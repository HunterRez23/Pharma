// lib/Screens/PantallaPrincipal.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Widgets/common_widgets.dart';           // Ruta a common_widgets
import 'detallesMedicamentos.dart';                // Pantalla de detalles
import '../Screens/Medicos.dart';            // Pantalla de médicos

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  Future<List<Map<String, dynamic>>> getMedicamentos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Medicamento')
        .get();
    final meds = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    meds.shuffle(Random());
    return meds;
  }

  void _openDetalles(Map<String, dynamic> med) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallesMedicamentoScreen(
          medicamento: med,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        showSearch: true,
        leadingIcon: Icons.menu,
        onLeadingPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onSearchSubmitted: (q) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Buscar: \$q'))),
        onFilterPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Filtro aún no implementado'))),
        onNotificationsPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Notificaciones'))),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
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
              leading: Icon(Icons.home),
              title: Text('Inicio'),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favoritos'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración'),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getMedicamentos(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final meds = snap.data ?? [];
          if (meds.isEmpty) {
            return const Center(child: Text('No hay medicamentos disponibles'));
          }
          final half = (meds.length / 2).ceil();
          final descuento = meds.sublist(0, half);
          final comunes = meds.sublist(half);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                const ImageCarousel(
                  images: [
                    'image/Similares.jpg',
                    'image/FarmaAhorro.jpg',
                    'image/SuperFarma.jpg',
                  ],
                ),
                const SizedBox(height: 20),

                // Medicamentos en descuento
                _buildSection(
                  title: 'Medicamentos en descuento',
                  items: descuento,
                ),

                const SizedBox(height: 10),

                // Medicamentos comunes
                _buildSection(
                  title: 'Medicamentos comunes',
                  items: comunes,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == 1) {
            // Botón del medio: navegar a la pantalla de médicos
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Medicos()),
            );
          }
          // Opcionalmente, actualizas el índice seleccionado
          setState(() {
            _selectedIndex = i;
          });
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
