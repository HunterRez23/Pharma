import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(PantallaPrincipal());
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
}

class PantallaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Obtiene los medicamentos desde Firestore, los mezcla aleatoriamente,
  /// y retorna la lista.
  Future<List<Map<String, dynamic>>> getMedicamentos() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Medicamento').get();
    List<Map<String, dynamic>> meds =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    meds.shuffle(Random());
    return meds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          YellowRectangle(
            child: Column(
              children: [
                Container(
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 90.0,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu),
                            color: Colors.white,
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          Expanded(child: SearchBox()),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            color: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Funcionalidad del carrito aún no implementada',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getMedicamentos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay medicamentos disponibles"));
                }
                // Dividir la lista en dos partes sin repetir
                List<Map<String, dynamic>> meds = snapshot.data!;
                int half = (meds.length / 2).ceil();
                List<Map<String, dynamic>> descuento = meds.sublist(0, half);
                List<Map<String, dynamic>> comunes = meds.sublist(half);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8.0),
                      const ImageCarousel(
                        images: [
                          'image/Similares.jpg',
                          'image/FarmaAhorro.jpg',
                          'image/SuperFarma.jpg',
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      // Sección: Medicamentos en descuento
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Medicamentos en descuento',
                                style: TextStyle(
                                  color: Color.fromARGB(235, 109, 141, 190),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: descuento.length,
                              itemBuilder: (context, index) {
                                final med = descuento[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Funcionalidad al pulsar
                                  },
                                  child: ProductRectangleWithText(
                                    imageUrl: med['imagenUrl'] ?? '',
                                    productName: med['nombreMedicamento'] ?? '',
                                    description: med['descripcion'] ?? '',
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // Sección: Medicamentos comunes
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Medicamentos comunes',
                                style: TextStyle(
                                  color: Color.fromARGB(235, 109, 141, 190),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comunes.length,
                              itemBuilder: (context, index) {
                                final med = comunes[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Funcionalidad al pulsar
                                  },
                                  child: ProductRectangleWithText(
                                    imageUrl: med['imagenUrl'] ?? '',
                                    productName: med['nombreMedicamento'] ?? '',
                                    description: med['descripcion'] ?? '',
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(152, 2, 56, 129),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 50.0, color: Colors.white),
                  SizedBox(height: 8.0),
                  Text(
                    'Admin',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Categorias'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 62,
        elevation: 0,
        color: const Color.fromARGB(215, 109, 141, 190),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.medical_services_outlined),
              color: Colors.white,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.healing_sharp),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

/// Clase para el rectángulo amarillo de cabecera
class YellowRectangle extends StatelessWidget {
  final Widget child;
  const YellowRectangle({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(184, 2, 50, 129),
      height: 120,
      width: double.infinity,
      child: child,
    );
  }
}

/// Caja de búsqueda (SearchBox)
class SearchBox extends StatefulWidget {
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(186, 125, 172, 211),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _isSearchEmpty ? 'Buscar' : '',
          hintStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              String searchTerm = _searchController.text;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Buscando: $searchTerm')));
            },
          ),
        ),
        onChanged: (value) {
          setState(() {
            _isSearchEmpty = value.isEmpty;
          });
        },
      ),
    );
  }
}

/// Carrusel de imágenes locales
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  const ImageCarousel({required this.images});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return RectangularImage(widget.images[index]);
        },
      ),
    );
  }
}

/// Imagen rectangular que se usa en el carrusel (usando imágenes locales)
class RectangularImage extends StatelessWidget {
  final String imagePath;
  const RectangularImage(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.blue, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 100.0,
          height: 100.0,
        ),
      ),
    );
  }
}

/// Rectángulo para mostrar cada medicamento con imagen y texto (sin precio)
class ProductRectangleWithText extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String description;

  const ProductRectangleWithText({
    required this.imageUrl,
    required this.productName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(152, 2, 56, 129),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Contenedor fijo para la imagen que se carga vía URL
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 80.0,
              height: 80.0,
              color: Colors.grey[300],
              child: Image.network(
                imageUrl.isNotEmpty
                    ? imageUrl
                    : 'https://via.placeholder.com/80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Información del medicamento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
