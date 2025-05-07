// lib/Screens/FavoritosScreen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detallesMedicamentos.dart';
import '../Widgets/common_widgets.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: CustomAppBar(
        showSearch: false,
        title: 'Favoritos',
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => Navigator.pop(context),
      ),
      body: user == null
          ? const Center(child: Text('Debes iniciar sesión'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(user.uid)
                  .collection('favoritos')
                  .snapshots(),
              builder: (context, favSnap) {
                if (favSnap.connectionState != ConnectionState.active) {
                  return const Center(child: CircularProgressIndicator());
                }
                final favDocs = favSnap.data?.docs ?? [];
                if (favDocs.isEmpty) {
                  return const Center(child: Text('No tienes favoritos aún'));
                }
                return ListView.builder(
                  itemCount: favDocs.length,
                  itemBuilder: (context, index) {
                    final medId = favDocs[index].id;
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Medicamento')
                          .doc(medId)
                          .get(),
                      builder: (context, medSnap) {
                        if (medSnap.connectionState == ConnectionState.waiting) {
                          return const SizedBox();
                        }
                        if (!medSnap.hasData || !medSnap.data!.exists) {
                          return const SizedBox();
                        }
                        final medData = medSnap.data!.data() as Map<String, dynamic>;
                        medData['id'] = medId;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Image.network(
                              medData['imagenUrl'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            ),
                            title: Text(
                              medData['nombreMedicamento'] ?? medData['nombre'] ?? '',
                            ),
                            subtitle: Text(medData['descripcion'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .doc(user.uid)
                                    .collection('favoritos')
                                    .doc(medId)
                                    .delete();
                              },
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetallesMedicamentoScreen(medicamento: medData),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
