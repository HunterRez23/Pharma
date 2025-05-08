import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMedico extends StatefulWidget {
  final String nombre;
  final String imagenUrl;

  const ChatMedico({
    super.key,
    required this.nombre,
    required this.imagenUrl,
  });

  @override
  State<ChatMedico> createState() => _ChatMedicoState();
}

class _ChatMedicoState extends State<ChatMedico> {
  final List<Map<String, dynamic>> _mensajes = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Mensajes de ejemplo
    _mensajes.addAll([
      {
        'texto': 'Hola, soy el Dr. Juan. ¿Cómo te sientes hoy?',
        'hora': '12:00',
        'esMio': false,
        'nombre': widget.nombre,
      },
      {
        'texto': 'Hola doctor, me siento mejor. Gracias.',
        'hora': '12:02',
        'esMio': true,
        'nombre': '',
      },
    ]);
  }

  void _enviarMensaje() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add({
        'texto': texto,
        'hora': TimeOfDay.now().format(context),
        'esMio': true,
        'nombre': '',
      });
    });

    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _obtenerIniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.isEmpty
        ? 'U'
        : partes.length == 1
            ? partes[0][0].toUpperCase()
            : '${partes[0][0].toUpperCase()}${partes[1][0].toUpperCase()}';
  }

  Widget _buildMensajeBurbuja({
    required String texto,
    required String hora,
    required bool esMio,
    required String nombre,
  }) {
    final bubbleColor = esMio ? const Color(0xFFD2ECFF) : const Color(0xFFEAF6FF);
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(esMio ? 12 : 0),
      bottomRight: Radius.circular(esMio ? 0 : 12),
    );

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bubbleColor, borderRadius: borderRadius),
      child: Column(
        crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(texto, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(hora, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!esMio)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade200,
              child: Text(
                _obtenerIniciales(nombre),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        bubble,
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              style: const TextStyle(color: Colors.black),
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF2F80ED)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF2F80ED)),
            onPressed: _enviarMensaje,
          ),
        ],
      ),
    );
  }

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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = _mensajes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildMensajeBurbuja(
                    texto: mensaje['texto'],
                    hora: mensaje['hora'],
                    esMio: mensaje['esMio'],
                    nombre: mensaje['nombre'] ?? widget.nombre,
                  ),
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }
}
