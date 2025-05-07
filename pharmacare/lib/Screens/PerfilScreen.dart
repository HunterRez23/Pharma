// lib/Screens/PerfilScreen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/common_widgets.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _bloodController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _diseasesController = TextEditingController();
  final TextEditingController _medsController = TextEditingController();
  final TextEditingController _pregnancyController = TextEditingController();

  DateTime? _birthDate;
  int _age = 0;

  late final String _uid;
  late final DocumentReference _profileRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _uid = user.uid;
    _profileRef = FirebaseFirestore.instance.collection('usuarios').doc(_uid);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final snap = await _profileRef.get();
    if (snap.exists) {
      final data = snap.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      if (data['birthDate'] != null) {
        _birthDate = (data['birthDate'] as Timestamp).toDate();
        _birthController.text = _formatDate(_birthDate!);
        _computeAge();
      }
      _sexController.text = data['sex'] ?? '';
      _bloodController.text = data['bloodType'] ?? '';
      _allergiesController.text = (data['allergies'] as List<dynamic>?)?.join(', ') ?? '';
      _diseasesController.text = (data['diseases'] as List<dynamic>?)?.join(', ') ?? '';
      _medsController.text = (data['medications'] as List<dynamic>?)?.join(', ') ?? '';
      _pregnancyController.text = data['pregnancy'] ?? '';
      setState(() {});
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }

  void _computeAge() {
    if (_birthDate == null) return;
    final today = DateTime.now();
    int age = today.year - _birthDate!.year;
    if (today.month < _birthDate!.month ||
        (today.month == _birthDate!.month && today.day < _birthDate!.day)) {
      age--;
    }
    _age = age;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthController.text = _formatDate(picked);
        _computeAge();
      });
    }
  }

  Future<void> _saveProfile() async {
    final profileData = {
      'name': _nameController.text.trim(),
      'birthDate': _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,
      'sex': _sexController.text.trim(),
      'bloodType': _bloodController.text.trim(),
      'allergies': _allergiesController.text.split(',').map((s) => s.trim()).toList(),
      'diseases': _diseasesController.text.split(',').map((s) => s.trim()).toList(),
      'medications': _medsController.text.split(',').map((s) => s.trim()).toList(),
      'pregnancy': _pregnancyController.text.trim(),
    };
    await _profileRef.set(profileData, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _sexController.dispose();
    _bloodController.dispose();
    _allergiesController.dispose();
    _diseasesController.dispose();
    _medsController.dispose();
    _pregnancyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        showSearch: false,
        title: 'Perfil',
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ??
                      'https://via.placeholder.com/100',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nombre Apellido',
                    ),
                  ),
                ),
                const Icon(Icons.edit, size: 20),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildRow('Fecha de nacimiento', _birthController, true, _pickBirthDate),
                    _buildRow('Edad', TextEditingController(text: '$_age años'), false, null),
                    _buildRow('Sexo', _sexController, false, null),
                    _buildRow('Grupo sanguíneo', _bloodController, false, null),
                    _buildRow('Alergias', _allergiesController, false, null),
                    _buildRow('Enfermedades', _diseasesController, false, null),
                    _buildRow('Medicamentos', _medsController, false, null),
                    _buildRow('Embarazo', _pregnancyController, false, null),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis documentos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Subir documento'))),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Subir'),
                ),
              ],
            ),
            // Aquí podrías listar documentos guardados
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, TextEditingController controller, bool readOnly,
      VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              decoration: const InputDecoration(border: InputBorder.none),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
