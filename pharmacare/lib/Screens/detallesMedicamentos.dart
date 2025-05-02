// lib/Screens/detallesMedicamentos.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/common_widgets.dart';

class DetallesMedicamentoScreen extends StatelessWidget {
  final Map<String, dynamic> medicamento;

  const DetallesMedicamentoScreen({
    Key? key,
    required this.medicamento,
  }) : super(key: key);

  /// Recupera las farmacias que tienen existencia de este medicamento
  Future<List<Map<String, dynamic>>> _fetchFarmacias() async {
    final medName = medicamento['nombreMedicamento'] as String;
    // Consulta en todas las subcolecciones 'Inventario'
    final invSnap = await FirebaseFirestore.instance
        .collectionGroup('Inventario')
        .where('nombreMedicamento', isEqualTo: medName)
        .get();

    final lista = <Map<String, dynamic>>[];
    for (var invDoc in invSnap.docs) {
      final invData = invDoc.data() as Map<String, dynamic>;
      // El padre de la subcolección 'Inventario' es el documento de la farmacia
      final farmRef = invDoc.reference.parent.parent;
      if (farmRef == null) continue;

      final farmDoc = await farmRef.get();
      if (!farmDoc.exists) continue;
      final farmData = farmDoc.data() as Map<String, dynamic>;

      lista.add({
        'nombre': farmData['nombre'] ?? '',
        'sucursal': farmData['sucursal'] ?? '',
        'horario': farmData['Horario'] ?? '',
        'latLng': farmData['LatLng'] ?? '',
        'cantidad': invData['cantidad'] ?? 0,
        'precio': invData['precio'] ?? 0,
      });
    }
    return lista;
  }

  /// Abre la app de navegación con las coordenadas lat,lng
  Future<void> _openLocation(String latLng) async {
    final uri = Uri.parse('google.navigation:q=$latLng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  medicamento['nombreMedicamento'] ?? '',
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
                final farms = snapshot.data ?? [];
                if (farms.isEmpty) {
                  return const Center(child: Text('No hay farmacias con existencia'));
                }
                return ListView.builder(
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final f = farms[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text('${f['nombre']} (${f['sucursal']})'),
                      subtitle: Text('Cantidad: ${f['cantidad']} • Precio: \$${f['precio']}'),
                      onTap: () => _openLocation(f['latLng'] as String),
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
