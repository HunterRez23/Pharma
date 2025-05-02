// lib/Screens/detallesMedicamentos.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/common_widgets.dart';

class DetallesMedicamentoScreen extends StatelessWidget {
  final Map<String, dynamic> medicamento;

  DetallesMedicamentoScreen({
    Key? key,
    required this.medicamento,
  }) : super(key: key);

  /// Recupera las farmacias que tienen existencia de este medicamento
  Future<List<Map<String, dynamic>>> _fetchFarmacias() async {
    final medName = medicamento['nombreMedicamento'] ?? medicamento['nombre'] ?? '';
    if (medName.isEmpty) {
      return [];
    }

    try {
      // Primero obtenemos todas las farmacias
      final farmaciasSnapshot = await FirebaseFirestore.instance
          .collection('Farmacias')
          .get();
      
      final lista = <Map<String, dynamic>>[];
      
      // Para cada farmacia, verificamos si tiene el medicamento en su inventario
      for (var farmaciaDoc in farmaciasSnapshot.docs) {
        final farmaciaData = farmaciaDoc.data();
        
        // Consultamos el inventario de esta farmacia buscando el medicamento
        final inventarioSnapshot = await farmaciaDoc.reference
            .collection('Inventario')
            .where('nombreMedicamento', isEqualTo: medName)
            .get();
        
        // Si hay al menos un documento, significa que esta farmacia tiene el medicamento
        if (inventarioSnapshot.docs.isNotEmpty) {
          final inventarioData = inventarioSnapshot.docs.first.data();
          
          lista.add({
            'nombre': farmaciaData['nombre'] ?? '',
            'sucursal': farmaciaData['sucursal'] ?? '',
            'horario': farmaciaData['Horario'] ?? '',
            'latLng': farmaciaData['LatLng'] ?? '',
            'precio': inventarioData['precio'] ?? 0,
          });
        }
      }
      
      return lista;
    } catch (e) {
      print('Error al obtener farmacias: $e');
      return [];
    }
  }

  /// Abre la app de navegación con las coordenadas lat,lng
  Future<void> _openLocation(String latLng) async {
    // Formatear coordenadas
    final coords = latLng.replaceAll(' ', '');
    final geoUri = Uri.parse('geo:$coords?q=$coords');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$coords');

    try {
      // Intent directo geo:
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Si no hay handler para geo:, fallback a navegador
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  // Para poder mostrar SnackBar en caso de error en openLocation
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        showSearch: false,
        title: 'Detalles',
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => Navigator.pop(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del medicamento
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicamento['nombreMedicamento'] ?? medicamento['nombre'] ?? '',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  medicamento['descripcion'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Image.network(
                    medicamento['imagenUrl'] ?? '',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Column(
                      children: [
                        Icon(Icons.pregnant_woman, size: 40),
                        SizedBox(height: 4),
                        Text('Embarazo'),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.local_hospital, size: 40),
                        SizedBox(height: 4),
                        Text('Vía'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Farmacias con existencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFarmacias(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final farms = snapshot.data ?? [];
                if (farms.isEmpty) {
                  return const Center(child: Text('No hay farmacias con existencia'));
                }
                
                return ListView.builder(
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final f = farms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.red),
                          title: Text('${f['nombre']} (${f['sucursal']})'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Horario: ${f['horario']}'),
                              Text('Precio: \$${f['precio']}'),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () => _openLocation(f['latLng']),
                                child: const Text('Abrir ubicación'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 20),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
