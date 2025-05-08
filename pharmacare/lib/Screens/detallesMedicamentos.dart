// lib/Screens/detallesMedicamentos.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/common_widgets.dart';

class DetallesMedicamentoScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;
  const DetallesMedicamentoScreen({Key? key, required this.medicamento}) : super(key: key);

  @override
  _DetallesMedicamentoScreenState createState() => _DetallesMedicamentoScreenState();
}

class _DetallesMedicamentoScreenState extends State<DetallesMedicamentoScreen> {
  bool _isFavorite = false;
  late String _uid;
  late String _medId;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _uid = user?.uid ?? '';
    _medId = widget.medicamento['id'] ??
        widget.medicamento['nombreMedicamento'] ??
        widget.medicamento['nombre'] ??
        '';
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    if (_uid.isEmpty) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_uid)
        .collection('favoritos')
        .doc(_medId)
        .get();
    setState(() => _isFavorite = doc.exists);
  }

  Future<void> _toggleFavorite() async {
    if (_uid.isEmpty) return;
    final favRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_uid)
        .collection('favoritos')
        .doc(_medId);
    try {
      if (_isFavorite) {
        await favRef.delete();
      } else {
        await favRef.set({
          'medicamentoId': _medId,
          'nombre': widget.medicamento['nombreMedicamento'] ??
              widget.medicamento['nombre'] ??
              '',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'Agregado a favoritos'
              : 'Eliminado de favoritos'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFarmacias() async {
    final medName = widget.medicamento['nombreMedicamento'] ??
        widget.medicamento['nombre'] ??
        '';
    if (medName.isEmpty) return [];
    try {
      final farmSnap =
          await FirebaseFirestore.instance.collection('Farmacias').get();
      final List<Map<String, dynamic>> lista = [];
      for (var farmaciaDoc in farmSnap.docs) {
        final farmaciaData = farmaciaDoc.data();
        final invSnap = await farmaciaDoc.reference
            .collection('Inventario')
            .where('nombreMedicamento', isEqualTo: medName)
            .get();
        if (invSnap.docs.isNotEmpty) {
          final invData = invSnap.docs.first.data();
          final horario = farmaciaData['horario'] ??
              farmaciaData['Horario'] ??
              '---';
          final precio = invData['precio'] ??
              invData['Precio'] ??
              0;
          lista.add({
            'nombre': farmaciaData['nombre'] ?? '',
            'sucursal': farmaciaData['sucursal'] ?? '',
            'horario': horario,
            'latLng': farmaciaData['latLng'] ??
                farmaciaData['LatLng'] ??
                '',
            'precio': precio,
          });
        }
      }
      return lista;
    } catch (e) {
      print('Error al obtener farmacias: $e');
      return [];
    }
  }

  Future<void> _openLocation(String latLng) async {
    final coords = latLng.replaceAll(' ', '');
    final geoUri = Uri.parse('geo:$coords?q=$coords');
    final webUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$coords');
    try {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        showSearch: false,
        title: 'Detalles',
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detalles del medicamento
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medicamento['nombreMedicamento'] ??
                      widget.medicamento['nombre'] ??
                      '',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.medicamento['descripcion'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Image.network(
                    widget.medicamento['imagenUrl'] ?? '',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 100),
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

          // Lista de farmacias
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFarmacias(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final farms = snap.data ?? [];
                if (farms.isEmpty) {
                  return const Center(
                      child: Text('No hay farmacias con existencia'));
                }
                return ListView.builder(
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final f = farms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading:
                            const Icon(Icons.location_on, color: Colors.red),
                        title:
                            Text("${f['nombre']} (${f['sucursal']})"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((f['horario'] as String).isNotEmpty)
                              Text("Horario: ${f['horario']}"),
                            Text("Precio: \$${f['precio']}"),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          if ((f['latLng'] as String).isNotEmpty) {
                            _openLocation(f['latLng']);
                          }
                        },
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
