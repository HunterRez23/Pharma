import 'package:flutter/material.dart';
import 'chatMedico.dart';
import '../widgets/common_widgets.dart'; // Asegúrate de que esta ruta sea correcta

class ChatSeguimiento extends StatelessWidget {
  const ChatSeguimiento({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        showSearch: false,
        title: 'Centro de mensajes',
        onLeadingPressed: () => Navigator.pop(context),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Aquí puedes agregar la lógica de navegación real
        },
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          _buildMensajeCard(
            context,
            nombre: 'Dr. Juan Pérez',
            mensaje: 'Hola, ¿cómo te has sentido desde la última consulta?',
            hora: '12:00',
          ),
          _buildMensajeCard(
            context,
            nombre: 'Dra. Lucía Gómez',
            mensaje: 'Te he enviado un archivo con tus resultados.',
            hora: '10:45',
          ),
        ],
      ),
    );
  }

  Widget _buildMensajeCard(
    BuildContext context, {
    required String nombre,
    required String mensaje,
    required String hora,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          radius: 24,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.expand_more, size: 16, color: Colors.grey),
          ],
        ),
        trailing: Text(
          hora,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatMedico(
                nombre: nombre,
                imagenUrl: '', // Puedes cargar una imagen real si la tienes
              ),
            ),
          );
        },
      ),
    );
  }
}
