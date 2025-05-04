// ✅ IMPORTACIONES
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BD/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subir Datos',
      home: UploadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // Controladores para Medicamento
  final _nombreMedicamentoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _sellosController = TextEditingController();
  final _imagenUrlController = TextEditingController();

  // Controladores para Farmacia
  final _idFarmaciaFieldController = TextEditingController();
  final _nombreFarmaciaController = TextEditingController();
  final _latLngController = TextEditingController();
  final _imagenUrlFarmaciaController = TextEditingController();
  final _sucursalController = TextEditingController();

  // Horarios dinámicos
  List<Map<String, String>> _horarios = [{'dia': '', 'inicio': '', 'fin': ''}];
  void _agregarHorario() {
    setState(() {
      _horarios.add({'dia': '', 'inicio': '', 'fin': ''});
    });
  }

  void _eliminarHorario(int index) {
    setState(() {
      _horarios.removeAt(index);
    });
  }

  List<Map<String, String>> _obtenerHorarios() => _horarios;

  Widget _buildHorarioInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Horarios (día, hora inicio, hora fin):", style: TextStyle(fontWeight: FontWeight.bold)),
        ..._horarios.asMap().entries.map((entry) {
          final index = entry.key;
          return Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Día'),
                  onChanged: (value) => _horarios[index]['dia'] = value,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Inicio'),
                  onChanged: (value) => _horarios[index]['inicio'] = value,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Fin'),
                  onChanged: (value) => _horarios[index]['fin'] = value,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _eliminarHorario(index),
              ),
            ],
          );
        }),
        TextButton.icon(
          onPressed: _agregarHorario,
          icon: Icon(Icons.add),
          label: Text("Agregar horario"),
        ),
      ],
    );
  }

  // Controladores para Inventario
  final _idFarmaciaController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioController = TextEditingController();
  String? _selectedMedicamento;

  // Controladores para Doctor
  final _nombreDoctorController = TextEditingController();
  final _licenciaController = TextEditingController();
  final _especialidadesController = TextEditingController();
  final _emailDoctorController = TextEditingController();
  final _telefonoDoctorController = TextEditingController();
  final _descripcionDoctorController = TextEditingController();
  final _honorarioController = TextEditingController();

  bool _isUploadingMedicamento = false;
  bool _isUploadingFarmacia = false;
  bool _isUploadingInventario = false;
  bool _isUploadingDoctor = false;

  Future<List<String>> _getMedicamentos() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Medicamento').get();
      return snapshot.docs.map((doc) => doc['nombreMedicamento'].toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _submitMedicamento() async {
    if (_nombreMedicamentoController.text.isEmpty ||
        _categoriaController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _sellosController.text.isEmpty ||
        _imagenUrlController.text.isEmpty) return;

    setState(() => _isUploadingMedicamento = true);
    final sellos = _sellosController.text.split(',').map((e) => e.trim()).toList();

    await FirebaseFirestore.instance.collection('Medicamento').add({
      'nombreMedicamento': _nombreMedicamentoController.text,
      'categoria': _categoriaController.text,
      'descripcion': _descripcionController.text,
      'sellosSeguridad': sellos,
      'imagenUrl': _imagenUrlController.text,
    });

    _nombreMedicamentoController.clear();
    _categoriaController.clear();
    _descripcionController.clear();
    _sellosController.clear();
    _imagenUrlController.clear();

    setState(() => _isUploadingMedicamento = false);
  }

  Future<void> _submitFarmacia() async {
    if (_idFarmaciaFieldController.text.isEmpty ||
        _nombreFarmaciaController.text.isEmpty ||
        _latLngController.text.isEmpty ||
        _imagenUrlFarmaciaController.text.isEmpty ||
        _sucursalController.text.isEmpty) return;

    setState(() => _isUploadingFarmacia = true);

    await FirebaseFirestore.instance.collection('Farmacias').add({
      'id_farmacia': _idFarmaciaFieldController.text,
      'nombre': _nombreFarmaciaController.text,
      'LatLng': _latLngController.text,
      'imagenUrl': _imagenUrlFarmaciaController.text,
      'sucursal': _sucursalController.text,
      'horarios': _obtenerHorarios(),
    });

    _idFarmaciaFieldController.clear();
    _nombreFarmaciaController.clear();
    _latLngController.clear();
    _imagenUrlFarmaciaController.clear();
    _sucursalController.clear();
    _horarios = [{'dia': '', 'inicio': '', 'fin': ''}];

    setState(() => _isUploadingFarmacia = false);
  }

  Future<void> _submitInventario() async {
    if (_idFarmaciaController.text.isEmpty || _selectedMedicamento == null) return;

    final query = await FirebaseFirestore.instance
        .collection('Farmacias')
        .where('id_farmacia', isEqualTo: _idFarmaciaController.text)
        .get();

    if (query.docs.isEmpty) return;

    final docRef = query.docs.first.reference;
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;
    final precio = double.tryParse(_precioController.text) ?? 0.0;

    await docRef.collection('Inventario').add({
      'nombreMedicamento': _selectedMedicamento,
      'cantidad': cantidad,
      'precio': precio,
      'ultimaActualizacion': DateTime.now().toIso8601String(),
    });

    _idFarmaciaController.clear();
    _cantidadController.clear();
    _precioController.clear();
    _selectedMedicamento = null;
  }

  Future<void> _submitDoctor() async {
    if (_nombreDoctorController.text.isEmpty ||
        _licenciaController.text.isEmpty ||
        _especialidadesController.text.isEmpty ||
        _emailDoctorController.text.isEmpty ||
        _telefonoDoctorController.text.isEmpty ||
        _descripcionDoctorController.text.isEmpty ||
        _honorarioController.text.isEmpty) return;

    setState(() => _isUploadingDoctor = true);
    final especialidades = _especialidadesController.text.split(',').map((e) => e.trim()).toList();

    await FirebaseFirestore.instance.collection('doctors').add({
      'fullName': _nombreDoctorController.text,
      'licenseNumber': _licenciaController.text,
      'specialties': especialidades,
      'contact': {
        'email': _emailDoctorController.text,
        'phone': _telefonoDoctorController.text,
      },
      'description': _descripcionDoctorController.text,
      'prices': {'consultationFee': double.tryParse(_honorarioController.text) ?? 0.0},
      'rating': {'average': 0.0, 'totalVotes': 0},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _nombreDoctorController.clear();
    _licenciaController.clear();
    _especialidadesController.clear();
    _emailDoctorController.clear();
    _telefonoDoctorController.clear();
    _descripcionDoctorController.clear();
    _honorarioController.clear();

    setState(() => _isUploadingDoctor = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agregar Datos")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Agregar Medicamento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: _nombreMedicamentoController, decoration: InputDecoration(labelText: 'Nombre')),
            TextField(controller: _categoriaController, decoration: InputDecoration(labelText: 'Categoría')),
            TextField(controller: _descripcionController, decoration: InputDecoration(labelText: 'Descripción')),
            TextField(controller: _sellosController, decoration: InputDecoration(labelText: 'Sellos (separados por comas)')),
            TextField(controller: _imagenUrlController, decoration: InputDecoration(labelText: 'Imagen URL')),
            _isUploadingMedicamento ? CircularProgressIndicator() : ElevatedButton(onPressed: _submitMedicamento, child: Text("Subir Medicamento")),

            SizedBox(height: 32),
            Text("Agregar Farmacia", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: _idFarmaciaFieldController, decoration: InputDecoration(labelText: 'ID Farmacia')),
            TextField(controller: _nombreFarmaciaController, decoration: InputDecoration(labelText: 'Nombre')),
            TextField(controller: _latLngController, decoration: InputDecoration(labelText: 'LatLng')),
            TextField(controller: _imagenUrlFarmaciaController, decoration: InputDecoration(labelText: 'Imagen URL')),
            TextField(controller: _sucursalController, decoration: InputDecoration(labelText: 'Sucursal')),
            _buildHorarioInputs(),
            _isUploadingFarmacia ? CircularProgressIndicator() : ElevatedButton(onPressed: _submitFarmacia, child: Text("Agregar Farmacia")),

            SizedBox(height: 32),
            Text("Agregar Inventario", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: _idFarmaciaController, decoration: InputDecoration(labelText: 'id_farmacia')),
            FutureBuilder<List<String>>(
              future: _getMedicamentos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return DropdownButtonFormField<String>(
                  value: _selectedMedicamento,
                  items: snapshot.data!.map((med) => DropdownMenuItem(value: med, child: Text(med))).toList(),
                  onChanged: (val) => setState(() => _selectedMedicamento = val),
                  decoration: InputDecoration(labelText: 'Medicamento'),
                );
              },
            ),
            TextField(controller: _cantidadController, decoration: InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number),
            TextField(controller: _precioController, decoration: InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
            _isUploadingInventario ? CircularProgressIndicator() : ElevatedButton(onPressed: _submitInventario, child: Text("Agregar Inventario")),

            SizedBox(height: 32),
            Text("Agregar Doctor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: _nombreDoctorController, decoration: InputDecoration(labelText: 'Nombre completo')),
            TextField(controller: _licenciaController, decoration: InputDecoration(labelText: 'Licencia')),
            TextField(controller: _especialidadesController, decoration: InputDecoration(labelText: 'Especialidades (separadas por comas)')),
            TextField(controller: _emailDoctorController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _telefonoDoctorController, decoration: InputDecoration(labelText: 'Teléfono')),
            TextField(controller: _descripcionDoctorController, decoration: InputDecoration(labelText: 'Descripción')),
            TextField(controller: _honorarioController, decoration: InputDecoration(labelText: 'Honorario'), keyboardType: TextInputType.number),
            _isUploadingDoctor ? CircularProgressIndicator() : ElevatedButton(onPressed: _submitDoctor, child: Text("Subir Doctor")),
          ],
        ),
      ),
    );
  }
}