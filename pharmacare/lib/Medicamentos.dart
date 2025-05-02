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
  final TextEditingController _nombreMedicamentoController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _sellosController = TextEditingController();
  final TextEditingController _imagenUrlController = TextEditingController();

  // Controladores para Farmacia
  final TextEditingController _idFarmaciaFieldController = TextEditingController(); // Campo id_farmacia
  final TextEditingController _nombreFarmaciaController = TextEditingController();
  final TextEditingController _latLngController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _imagenUrlFarmaciaController = TextEditingController();
  final TextEditingController _sucursalController = TextEditingController();

  // Controladores para Inventario (subcolección dentro de Farmacias)
  // Ahora se usará este campo para ingresar el valor del campo id_farmacia de la farmacia (no el documento ID)
  final TextEditingController _idFarmaciaController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  bool _isUploadingMedicamento = false;
  bool _isUploadingFarmacia = false;
  bool _isUploadingInventario = false;

  // Variable para el medicamento seleccionado en el combobox de Inventario
  String? _selectedMedicamento;

  // Función para obtener la lista de medicamentos usando el campo 'nombreMedicamento'
  Future<List<String>> _getMedicamentos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Medicamento').get();
      print("Docs encontrados: ${snapshot.docs.length}");
      List<String> medicamentos = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('nombreMedicamento')) {
          String med = data['nombreMedicamento'];
          print("✔ Medicamento encontrado: $med");
          medicamentos.add(med);
        } else {
          print("⚠ Documento sin campo 'nombreMedicamento': ${doc.id}");
        }
      }
      return medicamentos;
    } catch (e) {
      print("Error en _getMedicamentos(): $e");
      return [];
    }
  }

  // Función para subir medicamento a Firestore
  Future<void> _submitMedicamento() async {
    if (_nombreMedicamentoController.text.isEmpty ||
        _categoriaController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _sellosController.text.isEmpty ||
        _imagenUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos del medicamento.")),
      );
      return;
    }

    setState(() {
      _isUploadingMedicamento = true;
    });

    List<String> sellos = _sellosController.text.split(',').map((s) => s.trim()).toList();

    await FirebaseFirestore.instance.collection('Medicamento').add({
      'nombreMedicamento': _nombreMedicamentoController.text,
      'categoria': _categoriaController.text,
      'descripcion': _descripcionController.text,
      'sellosSeguridad': sellos,
      'imagenUrl': _imagenUrlController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Medicamento subido exitosamente.")),
    );

    // Limpiar campos
    _nombreMedicamentoController.clear();
    _categoriaController.clear();
    _descripcionController.clear();
    _sellosController.clear();
    _imagenUrlController.clear();

    setState(() {
      _isUploadingMedicamento = false;
    });
  }

  // Función para subir farmacia a Firestore
  Future<void> _submitFarmacia() async {
    if (_idFarmaciaFieldController.text.isEmpty ||
        _nombreFarmaciaController.text.isEmpty ||
        _latLngController.text.isEmpty ||
        _horarioController.text.isEmpty ||
        _imagenUrlFarmaciaController.text.isEmpty ||
        _sucursalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos de la farmacia.")),
      );
      return;
    }

    setState(() {
      _isUploadingFarmacia = true;
    });

    await FirebaseFirestore.instance.collection('Farmacias').add({
      'id_farmacia': _idFarmaciaFieldController.text,
      'nombre': _nombreFarmaciaController.text,
      'LatLng': _latLngController.text,
      'Horario': _horarioController.text,
      'imagenUrl': _imagenUrlFarmaciaController.text,
      'sucursal': _sucursalController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Farmacia agregada exitosamente.")),
    );

    // Limpiar campos
    _idFarmaciaFieldController.clear();
    _nombreFarmaciaController.clear();
    _latLngController.clear();
    _horarioController.clear();
    _imagenUrlFarmaciaController.clear();
    _sucursalController.clear();

    setState(() {
      _isUploadingFarmacia = false;
    });
  }

  // Función para agregar o actualizar un registro de inventario en la subcolección "Inventario"
  // de una farmacia, buscando la farmacia por el campo 'id_farmacia'
  Future<void> _submitInventario() async {
    if (_idFarmaciaController.text.isEmpty ||
        _selectedMedicamento == null ||
        _cantidadController.text.isEmpty ||
        _precioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos del inventario.")),
      );
      return;
    }

    setState(() {
      _isUploadingInventario = true;
    });

    // Buscar la farmacia utilizando el campo 'id_farmacia'
    QuerySnapshot farmaciaQuery = await FirebaseFirestore.instance
        .collection('Farmacias')
        .where('id_farmacia', isEqualTo: _idFarmaciaController.text)
        .get();

    if (farmaciaQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se encontró la farmacia con el id_farmacia indicado.")),
      );
      setState(() {
        _isUploadingInventario = false;
      });
      return;
    }

    // Obtener la referencia del primer documento que cumpla la condición
    DocumentReference farmaciaDoc = farmaciaQuery.docs.first.reference;

    // Buscar si ya existe un documento de inventario para el medicamento seleccionado
    QuerySnapshot invQuery = await farmaciaDoc
        .collection('Inventario')
        .where('nombreMedicamento', isEqualTo: _selectedMedicamento)
        .get();

    int nuevaCantidad = int.tryParse(_cantidadController.text) ?? 0;
    double nuevoPrecio = double.tryParse(_precioController.text) ?? 0.0;

    if (invQuery.docs.isNotEmpty) {
      // Si existe, actualizamos el documento (sumamos la cantidad y actualizamos el precio y la fecha)
      DocumentReference invDoc = invQuery.docs.first.reference;
      int cantidadExistente = invQuery.docs.first.get('cantidad') as int;
      await invDoc.update({
        'cantidad': cantidadExistente + nuevaCantidad,
        'precio': nuevoPrecio,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inventario actualizado exitosamente.")),
      );
    } else {
      // Si no existe, creamos un nuevo documento en la subcolección "Inventario"
      await farmaciaDoc.collection('Inventario').add({
        'nombreMedicamento': _selectedMedicamento,
        'cantidad': nuevaCantidad,
        'precio': nuevoPrecio,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inventario agregado exitosamente.")),
      );
    }

    // Limpiar campos del inventario
    _idFarmaciaController.clear();
    setState(() {
      _selectedMedicamento = null;
    });
    _cantidadController.clear();
    _precioController.clear();

    setState(() {
      _isUploadingInventario = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Datos"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección para Medicamento
            Text(
              "Agregar Medicamento",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            TextField(
              controller: _nombreMedicamentoController,
              decoration: InputDecoration(labelText: 'Nombre del Medicamento'),
            ),
            TextField(
              controller: _categoriaController,
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _sellosController,
              decoration: InputDecoration(
                labelText: 'Sellos de seguridad (separados por comas)',
              ),
            ),
            TextField(
              controller: _imagenUrlController,
              decoration: InputDecoration(
                labelText: 'URL de la imagen del medicamento',
              ),
            ),
            SizedBox(height: 16),
            _isUploadingMedicamento
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitMedicamento,
                    child: Text("Subir Medicamento"),
                  ),
            SizedBox(height: 32),
            // Sección para Farmacia
            Text(
              "Agregar Farmacia",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            TextField(
              controller: _idFarmaciaFieldController,
              decoration: InputDecoration(
                labelText: 'ID de la Farmacia',
                hintText: 'Ingrese el ID de la farmacia',
              ),
            ),
            TextField(
              controller: _nombreFarmaciaController,
              decoration: InputDecoration(labelText: 'Nombre de la farmacia'),
            ),
            TextField(
              controller: _latLngController,
              decoration: InputDecoration(labelText: 'LatLng (ej. 31.3167, -113.5333)'),
            ),
            TextField(
              controller: _horarioController,
              decoration: InputDecoration(labelText: 'Horario (ej. 7:00am-9:00pm)'),
            ),
            TextField(
              controller: _imagenUrlFarmaciaController,
              decoration: InputDecoration(labelText: 'URL de la imagen de la farmacia'),
            ),
            TextField(
              controller: _sucursalController,
              decoration: InputDecoration(labelText: 'Sucursal'),
            ),
            SizedBox(height: 16),
            _isUploadingFarmacia
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitFarmacia,
                    child: Text("Agregar Farmacia"),
                  ),
            SizedBox(height: 32),
            // Sección para Inventario
            Text(
              "Agregar Inventario a una Farmacia",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            // En este campo se ingresa el valor de id_farmacia (no el documento ID) que se usará para buscar la farmacia
            TextField(
              controller: _idFarmaciaController,
              decoration: InputDecoration(
                labelText: 'id_farmacia de la Farmacia',
                hintText: 'Ingrese el valor id_farmacia de la farmacia',
              ),
            ),
            FutureBuilder<List<String>>(
              future: _getMedicamentos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No hay medicamentos disponibles");
                }
                List<String> medicamentos = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Nombre del Medicamento'),
                  value: _selectedMedicamento,
                  items: medicamentos
                      .map((med) => DropdownMenuItem<String>(
                            child: Text(med),
                            value: med,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMedicamento = value;
                    });
                  },
                );
              },
            ),
            TextField(
              controller: _cantidadController,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _precioController,
              decoration: InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _isUploadingInventario
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitInventario,
                    child: Text("Agregar Inventario"),
                  ),
          ],
        ),
      ),
    );
  }
}
