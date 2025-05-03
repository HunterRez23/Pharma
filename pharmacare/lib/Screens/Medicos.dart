import 'package:flutter/material.dart';
import '../Widgets/common_widgets.dart'; // Para CustomAppBar, CustomBottomNavBar
import './detallesMedico.dart'; // Importamos la nueva pantalla

class Doctor {
  final String name;
  final String specialty;
  final String imageUrl;

  const Doctor({
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });
}

class Medicos extends StatefulWidget {
  const Medicos({Key? key}) : super(key: key);

  @override
  State<Medicos> createState() => _MedicosState();
}

class _MedicosState extends State<Medicos> {
  static const _lightGrey = Color(0xFFF1F2F6);
  static const _primaryBlue = Color.fromARGB(255, 1, 76, 138);

  int _selectedIndex = 1; // Marca “Médicos” como pestaña activa

  final List<Map<String, dynamic>> specialties = const [
    { 'name': 'General',      'icon': Icons.medical_services },
    { 'name': 'Pediatra',     'icon': Icons.child_care },
    { 'name': 'Dentista',     'icon': Icons.health_and_safety },
    { 'name': 'Cardiólogo',   'icon': Icons.favorite },
    { 'name': 'Psicólogo',    'icon': Icons.psychology },
    { 'name': 'Fisioterapeuta','icon': Icons.fitness_center },
    { 'name': 'Nutriólogo',   'icon': Icons.fastfood },
  ];

  final List<Doctor> generalDoctors = const [
    Doctor(name: 'Dr. Nombre Doctor',     specialty: 'Médico General', imageUrl: 'https://via.placeholder.com/150'),
    Doctor(name: 'Dra. Nombre Doctora',   specialty: 'Médico General', imageUrl: 'https://via.placeholder.com/150'),
    Doctor(name: 'Dr. Otro Médico',       specialty: 'Médico General', imageUrl: 'https://via.placeholder.com/150'),
    Doctor(name: 'Dr. Nombre Especialista', specialty: 'Especialista', imageUrl: 'https://via.placeholder.com/150'),
  ];

  final List<Doctor> specialists = const [
    Doctor(name: 'Dr. Nombre Especialista',   specialty: 'Especialista', imageUrl: 'https://via.placeholder.com/150'),
    Doctor(name: 'Dra. Otra Especialista',    specialty: 'Especialista', imageUrl: 'https://via.placeholder.com/150'),
    Doctor(name: 'Dr. Tercer Especialista',   specialty: 'Especialista', imageUrl: 'https://via.placeholder.com/150'),
    Doctor(name: 'Dra. Cuarta Especialista',  specialty: 'Especialista', imageUrl: 'https://via.placeholder.com/150'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showSearch: true,
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => Navigator.of(context).pop(),
        onSearchSubmitted: (q) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Buscar médico: $q'))),
        onFilterPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Filtro no implementado'))),
        onNotificationsPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Notificaciones'))),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Slider de especialidades
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
                    onTap: () => debugPrint('Seleccionaste ${spec['name']}'),
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

            // Sección Médicos Generales
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Médicos generales',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _primaryBlue),
              ),
            ),
            ...generalDoctors.map((d) => DoctorCard(doctor: d)),

            const SizedBox(height: 24),

            // Sección Especialistas
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Especialistas',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _primaryBlue),
              ),
            ),
            ...specialists.map((d) => DoctorCard(doctor: d)),
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DetallesMedico()),
        );
      },
      child: Container(
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
      ),
    );
  }
}
