import 'package:flutter/material.dart';
import 'chatMedico.dart';

class ChatSeguimiento extends StatelessWidget {
  const ChatSeguimiento({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Centro de mensajes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMensajeCard(
            context,
            nombre: 'Nombre medico',
            mensaje: 'Texto mensaje',
            hora: '12:00',
            imagenUrl:
                'https://via.placeholder.com/150', // Puedes reemplazar esto
          ),
          // Puedes duplicar esto para más mensajes
        ],
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imagenUrl),
          radius: 25,
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              mensaje,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
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
        imagenUrl: imagenUrl,
      ),
    ),
  );
},

      ),
    );
  }
}
