import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharmacare/Screens/chatMedico.dart';

class FormularioAgendarCita extends StatefulWidget {
  final String nombreDoctor;

  const FormularioAgendarCita({super.key, required this.nombreDoctor});

  @override
  State<FormularioAgendarCita> createState() => _FormularioAgendarCitaState();
}

class _FormularioAgendarCitaState extends State<FormularioAgendarCita> {
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  final TextEditingController _motivoController = TextEditingController();
  bool _realizarEvaluacion = false;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() => _horaSeleccionada = hora);
    }
  }

  Future<void> _guardarCita() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    if (_fechaSeleccionada == null ||
        _horaSeleccionada == null ||
        _motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final cita = {
      'doctor': widget.nombreDoctor,
      'motivo': _motivoController.text.trim(),
      'fecha': _fechaSeleccionada!.toIso8601String(),
      'hora': _horaSeleccionada!.format(context),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('Citas')
          .add(cita);

      Navigator.pop(context); // Cierra modal

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita agendada exitosamente')),
      );

      if (_realizarEvaluacion) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatMedico(
              nombre: 'Evaluación por IA',
              imagenUrl: '',
              mensajesIniciales: [
                {
                  'texto': 'Gracias. Iniciando prevaloración por IA.',
                  'hora': TimeOfDay.now().format(context),
                  'esMio': false,
                  'nombre': 'IA',
                },
                {
                  'texto': 'Por favor, escribe tu síntoma principal para comenzar.',
                  'hora': TimeOfDay.now().format(context),
                  'esMio': false,
                  'nombre': 'IA',
                },
              ],
            ),
          ),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la cita: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Agendar cita',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F80ED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motivoController,
              decoration: InputDecoration(
                labelText: 'Motivo de la consulta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarFecha(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_fechaSeleccionada == null
                        ? 'Seleccionar fecha'
                        : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarHora(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(_horaSeleccionada == null
                        ? 'Hora'
                        : _horaSeleccionada!.format(context)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifique la disponibilidad de la fecha y hora antes de agendar.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Checkbox de evaluación por IA
            CheckboxListTile(
              value: _realizarEvaluacion,
              onChanged: (value) => setState(() {
                _realizarEvaluacion = value ?? false;
              }),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Realizar prevaloración por IA tras agendar',
                style: TextStyle(fontSize: 14),
              ),
              activeColor: Color(0xFF2F80ED),
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _guardarCita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Agendar cita',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
