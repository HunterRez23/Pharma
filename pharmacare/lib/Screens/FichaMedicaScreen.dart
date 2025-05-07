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
    final user = FirebaseAuth.instance.currentUser;
    final docRef = FirebaseFirestore.instance.collection('usuarios').doc(user!.uid);

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
          final data = snap.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '';
          final birth = data['birthDate'] != null
              ? (data['birthDate'] as Timestamp).toDate()
              : null;
          final age = birth != null
              ? DateTime.now().year - birth.year -
                  ((DateTime.now().month < birth.month ||
                          (DateTime.now().month == birth.month &&
                              DateTime.now().day < birth.day))
                      ? 1
                      : 0)
              : null;
          final sex = data['sex'] ?? '';
          final blood = data['bloodType'] ?? '';
          final meds = (data['medications'] as List<dynamic>?)?.join(', ') ?? '---';
          final alergias = (data['allergies'] as List<dynamic>?)?.join(', ') ?? '---';
          final emergency = (data['emergencyContacts'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .join(', ') ??
              '---';
          final padecimientos =
              (data['diseases'] as List<dynamic>?)?.join(', ') ?? '---';
          final height = data['height']?.toString() ?? '---';
          final weight = data['weight']?.toString() ?? '---';
          final languages = (data['languages'] as List<dynamic>?)?.join(', ') ?? '---';

          Widget section(String title, String value, VoidCallback onEdit) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('Editar'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información', style: TextStyle(color: Colors.blue)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (age != null)
                            Text('\$age años'),
                          if (sex.isNotEmpty) Text(sex),
                          if (blood.isNotEmpty) Text('Grupo sanguíneo \$blood'),
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
                const Divider(),
                section('Medicamentos', meds, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                }),
                Text(meds),
                const Divider(),
                section('Alergias', alergias, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                }),
                Text(alergias),
                const Divider(),
                section('Contactos de emergencia', emergency, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                }),
                Text(emergency),
                const Divider(),
                section('Padecimientos', padecimientos, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                }),
                Text(padecimientos),
                const Divider(),
                section('Más información', '', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                }),
                Text('Estatura: \$height m'),
                Text('Peso: \$weight kg'),
                Text('Idiomas: \$languages'),
              ],
            ),
          );
        },
      ),
    );
  }
}
