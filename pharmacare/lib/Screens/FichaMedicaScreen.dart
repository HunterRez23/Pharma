// lib/Screens/FichaMedicaScreen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Widgets/common_widgets.dart';
import 'PerfilScreen.dart';

class FichaMedicaScreen extends StatelessWidget {
  const FichaMedicaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final docRef =
        FirebaseFirestore.instance.collection('usuarios').doc(user.uid);

    return Scaffold(
      appBar: CustomAppBar(
        showSearch: false,
        title: 'Ficha médica',
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => Navigator.pop(context),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('No hay información disponible'));
          }

          final data = snap.data!.data()! as Map<String, dynamic>;

          final name = data['name'] as String? ?? '';
          final birthTs = data['birthDate'] as Timestamp?;
          final birth = birthTs?.toDate();
          final age = birth != null
              ? DateTime.now().year - birth.year -
                  ((DateTime.now().month < birth.month ||
                          (DateTime.now().month == birth.month &&
                              DateTime.now().day < birth.day))
                      ? 1
                      : 0)
              : null;
          final sex = data['sex'] as String? ?? '';
          final blood = data['bloodType'] as String? ?? '';

          // Medicamentos y alergias como cadena o '---' si vacíos
          final medsList = data['medications'] as List<dynamic>?;
          final meds = (medsList != null && medsList.isNotEmpty)
              ? medsList.map((e) => e.toString()).join(', ')
              : '---';
          final alergiasList = data['allergies'] as List<dynamic>?;
          final alergias = (alergiasList != null && alergiasList.isNotEmpty)
              ? alergiasList.map((e) => e.toString()).join(', ')
              : '---';

          // Otros campos
          final emergencyList = data['emergencyContacts'] as List<dynamic>?;
          final emergency = (emergencyList != null && emergencyList.isNotEmpty)
              ? emergencyList.map((e) => e.toString()).join(', ')
              : '---';
          final diseasesList = data['diseases'] as List<dynamic>?;
          final padecimientos = (diseasesList != null && diseasesList.isNotEmpty)
              ? diseasesList.map((e) => e.toString()).join(', ')
              : '---';
          final height = data['height']?.toString() ?? '---';
          final weight = data['weight']?.toString() ?? '---';
          final languagesList = data['languages'] as List<dynamic>?;
          final languages = (languagesList != null && languagesList.isNotEmpty)
              ? languagesList.map((e) => e.toString()).join(', ')
              : '---';

          Widget section(String title, VoidCallback onEdit) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(onPressed: onEdit, child: const Text('Editar')),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          if (age != null) Text('$age años'),
                          if (sex.isNotEmpty) Text(sex),
                          if (blood.isNotEmpty)
                            Text('Grupo sanguíneo $blood'),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        user.photoURL ?? 'https://via.placeholder.com/80',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),

                // Medicamentos
                section('Medicamentos', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()),
                  );
                }),
                Text(meds),
                const Divider(),

                // Alergias
                section('Alergias', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()),
                  );
                }),
                Text(alergias),
                const Divider(),

                // Contactos de emergencia
                section('Contactos de emergencia', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()),
                  );
                }),
                Text(emergency),
                const Divider(),

                // Padecimientos
                section('Padecimientos', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()),
                  );
                }),
                Text(padecimientos),
                const Divider(),

                // Más información
                section('Más información', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()),
                  );
                }),
                Text('Estatura: $height m'),
                Text('Peso: $weight kg'),
                Text('Idiomas: $languages'),
              ],
            ),
          );
        },
      ),
    );
  }
}
