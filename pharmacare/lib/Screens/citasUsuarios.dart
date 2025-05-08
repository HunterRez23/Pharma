import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Widgets/common_widgets.dart';

class CitasUsuario extends StatefulWidget {
  const CitasUsuario({Key? key}) : super(key: key);

  @override
  State<CitasUsuario> createState() => _CitasUsuarioState();
}

class _CitasUsuarioState extends State<CitasUsuario> {
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _citas;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _citas = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('Citas')
          .orderBy('fecha')
          .get()
          .then((snapshot) => snapshot.docs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        showSearch: false,
        title: 'Historial de citas',
        onLeadingPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _citas,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final citas = snapshot.data!;
            final ahora = DateTime.now();
            final futuras = citas.where((c) {
              final fecha = DateTime.tryParse(c['fecha'] ?? '');
              return fecha != null && fecha.isAfter(ahora);
            }).toList();

            final pasadas = citas.where((c) {
              final fecha = DateTime.tryParse(c['fecha'] ?? '');
              return fecha != null && !fecha.isAfter(ahora);
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Próximas citas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  futuras.isEmpty
                      ? const Text('No tienes citas próximas.')
                      : Column(
                          children: futuras.map((doc) => _buildCitaCard(doc)).toList(),
                        ),
                  const SizedBox(height: 24),
                  const Text(
                    'Citas pasadas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  pasadas.isEmpty
                      ? const Text('No hay citas pasadas registradas.')
                      : Column(
                          children: pasadas.map((doc) => _buildCitaCard(doc, pasada: true)).toList(),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCitaCard(QueryDocumentSnapshot<Map<String, dynamic>> doc, {bool pasada = false}) {
    final data = doc.data();
    final fecha = DateTime.tryParse(data['fecha'] ?? '');
    final hora = data['hora'] ?? '';
    final motivo = data['motivo'] ?? 'Asunto cita';
    final doctor = data['doctor'] ?? 'Nombre Apellido';
    final fechaTexto = fecha != null
        ? '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}'
        : 'Fecha no disponible';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(motivo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Fecha: $fechaTexto'),
          Text('Hora: $hora'),
          const Text('Clínica: Nombre clínica'),
          Text('Doctor: $doctor'),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: pasada
                ? TextButton(
                    onPressed: () {},
                    child: const Text('Ver detalles'),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // lógica para reagendar
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                        child: const Text('Reagendar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(uid)
                                .collection('Citas')
                                .doc(doc.id)
                                .delete();
                            setState(() {
                              _citas = FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(uid)
                                  .collection('Citas')
                                  .orderBy('fecha')
                                  .get()
                                  .then((s) => s.docs);
                            });
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cancelar cita'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
