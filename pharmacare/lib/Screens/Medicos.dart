// lib/Screens/Medicos.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import '../Widgets/common_widgets.dart'; // Para CustomAppBar, CustomBottomNavBar

class Doctor {
  final String name;
  final String specialty;
  final String imageUrl;

  const Doctor({
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });

  factory Doctor.fromMap(Map<String, dynamic> data) {
    return Doctor(
      name: data['fullName'] ?? 'Sin nombre',
      specialty: (data['specialties'] as List<dynamic>).isNotEmpty ? data['specialties'][0] : 'General',
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}

class Medicos extends StatefulWidget {
  const Medicos({Key? key}) : super(key: key);

  @override
  State<Medicos> createState() => _MedicosState();
}

class _MedicosState extends State<Medicos> {
  static const _lightGrey = Color(0xFFF1F2F6);
  static const _primaryBlue = Color.fromARGB(255, 1, 76, 138);

  int _selectedIndex = 1;
  String? _filtroEspecialidad;

  final List<Map<String, dynamic>> specialties = const [
    { 'name': 'General',      'icon': Icons.medical_services },
    { 'name': 'Pediatra',     'icon': Icons.child_care },
    { 'name': 'Dentista',     'icon': Icons.health_and_safety },
    { 'name': 'Cardiólogo',   'icon': Icons.favorite },
    { 'name': 'Psicólogo',    'icon': Icons.psychology },
    { 'name': 'Fisioterapeuta','icon': Icons.fitness_center },
    { 'name': 'Nutriólogo',   'icon': Icons.fastfood },
  ];

  List<Doctor> _todosLosDoctores = [];

  @override
  void initState() {
    super.initState();
    _cargarDoctoresDesdeFirestore();
  }

  Future<void> _cargarDoctoresDesdeFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('doctors').get();
    final doctores = snapshot.docs.map((doc) => Doctor.fromMap(doc.data())).toList();
    setState(() {
      _todosLosDoctores = doctores;
    });
  }

  List<Doctor> get _doctoresFiltrados {
    if (_filtroEspecialidad == null) return _todosLosDoctores;
    final filtro = removeDiacritics(_filtroEspecialidad!.toLowerCase());
    return _todosLosDoctores.where((doc) {
      final docSpecialty = removeDiacritics(doc.specialty.toLowerCase());
      return docSpecialty.contains(filtro);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showSearch: true,
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => Navigator.of(context).pop(),
        onSearchSubmitted: (q) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Buscar médico: \$q'))),
        onFilterPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Filtro no implementado'))),
        onNotificationsPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Notificaciones'))),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Slider de especialidades con filtro
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: specialties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final spec = specialties[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _filtroEspecialidad = spec['name'];
                      });
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _lightGrey,
                          child: Icon(spec['icon'] as IconData, size: 30, color: _primaryBlue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          spec['name'] as String,
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500, color: _primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _filtroEspecialidad == null
                        ? 'Todos los médicos'
                        : 'Especialidad: ${_filtroEspecialidad!}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _primaryBlue),
                  ),
                  if (_filtroEspecialidad != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() => _filtroEspecialidad = null);
                      },
                    ),
                ],
              ),
            ),
            ..._doctoresFiltrados.map((d) => DoctorCard(doctor: d)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i != 1) Navigator.of(context).popUntil((r) => r.isFirst);
          setState(() => _selectedIndex = i);
        },
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const DoctorCard({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _MedicosState._lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(doctor.imageUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(doctor.specialty, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}