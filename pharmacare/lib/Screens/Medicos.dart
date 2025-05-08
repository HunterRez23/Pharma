import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diacritic/diacritic.dart';
import 'package:pharmacare/Screens/PantallaPrincipal.dart';
import 'package:pharmacare/Screens/chatSeguimiento.dart';
import 'package:pharmacare/Screens/PerfilScreen.dart';
import 'package:pharmacare/Screens/FavoritosScreen.dart';
import 'package:pharmacare/Screens/FichaMedicaScreen.dart';
import '../Widgets/common_widgets.dart';
import '../Modelos/doctor.dart';
import 'detallesMedico.dart';

class Medicos extends StatefulWidget {
  const Medicos({Key? key}) : super(key: key);

  @override
  State<Medicos> createState() => _MedicosState();
}

class _MedicosState extends State<Medicos> {
  static const _lightGrey = Color(0xFFF1F2F6);
  static const _primaryBlue = Color.fromARGB(255, 1, 76, 138);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;
  String? _filtroEspecialidad;

  final List<String> categorias = [
    'General',
    'Pediatra',
    'Dentista',
    'Cardiólogo',
    'Psicólogo',
    'Fisioterapeuta',
    'Nutriólogo'
  ];

  List<Doctor> _todosLosDoctores = [];

  @override
  void initState() {
    super.initState();
    _cargarDoctoresDesdeFirestore();
  }

  Future<void> _cargarDoctoresDesdeFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();
    final doctores =
        snapshot.docs.map((doc) => Doctor.fromMap(doc.data())).toList();
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
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(152, 2, 56, 129)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Admin',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            _drawerItem(Icons.home, 'Inicio', () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const PantallaPrincipal()));
            }),
            _drawerItem(Icons.person, 'Perfil', () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PerfilScreen()));
            }),
            _drawerItem(Icons.calendar_today, 'Mis citas', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Mis citas')));
            }),
            _drawerItem(Icons.favorite, 'Favoritos', () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FavoritosScreen()));
            }),
            _drawerItem(Icons.category, 'Categorías', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Categorías')));
            }),
            _drawerItem(Icons.medical_services, 'Ficha médica', () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FichaMedicaScreen()));
            }),
            _drawerItem(Icons.settings, 'Configuración', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Configuración')));
            }),
            const Divider(),
            _drawerItem(Icons.logout, 'Cerrar sesión', () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ],
        ),
      ),
      appBar: CustomAppBar(
        showSearch: true,
        leadingIcon: Icons.menu,
        onLeadingPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onSearchSubmitted: (q) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Buscar médico: $q'))),
        onFilterPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Filtro no implementado'))),
        onNotificationsPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Notificaciones'))),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categorias.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = categorias[i];
                  final isSelected = _filtroEspecialidad == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(
                          () => _filtroEspecialidad = isSelected ? null : cat);
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 30, // Altura mínima deseada
                        maxHeight: 36, // Altura máxima fija
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 1.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14, // puedes ajustar tamaño para que quepa
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _filtroEspecialidad == null
                        ? 'Todos los médicos'
                        : 'Especialidad: $_filtroEspecialidad',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _primaryBlue),
                  ),
                  if (_filtroEspecialidad != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () =>
                          setState(() => _filtroEspecialidad = null),
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
          if (i == _selectedIndex) return;
          setState(() => _selectedIndex = i);
          Widget destino;
          switch (i) {
            case 0:
              destino = const PantallaPrincipal();
              break;
            case 1:
              destino = const Medicos();
              break;
            case 2:
              destino = const ChatSeguimiento();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => destino));
        },
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const DoctorCard({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetallesMedico(doctor: doctor))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _MedicosState._lightGrey,
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            CircleAvatar(
                radius: 30, backgroundImage: NetworkImage(doctor.imageUrl)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
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
