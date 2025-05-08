import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharmacare/Screens/PantallaPrincipal.dart';
import 'package:pharmacare/Screens/Medicos.dart';
import 'package:pharmacare/Screens/PerfilScreen.dart';
import 'package:pharmacare/Screens/FavoritosScreen.dart';
import 'package:pharmacare/Screens/FichaMedicaScreen.dart';
import '../Widgets/common_widgets.dart';
import 'chatMedico.dart';

class ChatSeguimiento extends StatefulWidget {
  const ChatSeguimiento({Key? key}) : super(key: key);

  @override
  _ChatSeguimientoState createState() => _ChatSeguimientoState();
}

class _ChatSeguimientoState extends State<ChatSeguimiento> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;

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
            _drawerItem(Icons.home, 'Inicio', const PantallaPrincipal()),
            _drawerItem(Icons.person, 'Perfil', const PerfilScreen()),
            _drawerItem(Icons.calendar_today, 'Mis citas'),
            _drawerItem(Icons.favorite, 'Favoritos', const FavoritosScreen()),
            _drawerItem(Icons.category, 'Categorías'),
            _drawerItem(Icons.medical_services, 'Ficha médica', const FichaMedicaScreen()),
            _drawerItem(Icons.settings, 'Configuración'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      appBar: CustomAppBar(
        showSearch: false,
        title: 'Centro de mensajes',
        leadingIcon: Icons.menu,
        onLeadingPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          _buildMensajeCard(
            context,
            nombre: 'Dr. Juan Pérez',
            mensaje: 'Hola, ¿cómo te has sentido desde la última consulta?',
            hora: '12:00',
            imagenUrl: 'https://via.placeholder.com/150',
          ),
        ],
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
            context,
            MaterialPageRoute(builder: (_) => destino),
          );
        },
      ),
    );
  }

  Widget _buildMensajeCard(BuildContext context,
      {required String nombre,
      required String mensaje,
      required String hora,
      required String imagenUrl}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imagenUrl),
          radius: 25,
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 16, color: Colors.grey),
          ],
        ),
        trailing: Text(
          hora,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatMedico(nombre: nombre, imagenUrl: imagenUrl),
            ),
          );
        },
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, [Widget? page]) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(title)));
        }
      },
    );
  }
}
