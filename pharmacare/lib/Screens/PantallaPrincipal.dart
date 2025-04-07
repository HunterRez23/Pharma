import 'dart:async';
import 'package:flutter/material.dart';


void main() {
  runApp(PantallaPrincipal());
}

class PantallaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, String>> productos = [
    {
      'imagePath': 'image/Aspirina.png',
      'productName': 'Aspirina',
      'description': 'Descripción de Aspirina',
      'price': '\$19.99',
    },
    {
      'imagePath': 'image/Tylenol1.png',
      'productName': 'Tylenol',
      'description': 'Descripción de Tylenol',
      'price': '\$19.99',
    },
    {
      'imagePath': 'image/Paracetamol.png',
      'productName': 'Paracetamol',
      'description': 'Descripción de Paracetamol',
      'price': '\$19.99',
    },
    {
      'imagePath': 'image/Omeprazol.png',
      'productName': 'Omeprazol',
      'description': 'Descripción de Omeprazol',
      'price': '\$19.99',
    },
  ];

  final List<Map<String, String>> Productos2 = [
    {
      'imagePath': 'image/Levotiroxina.png',
      'productName': 'Levotiroxina sodica',
      'description': 'Descripción de Levotiroxina sodica',
      'price': '\$29.99',
    },
    {
      'imagePath': 'image/Amlodipina.png',
      'productName': 'Amlodipina',
      'description': 'Descripción de Amlodipina',
      'price': '\$29.99',
    },
    {
      'imagePath': 'image/Dexametasona.png',
      'productName': 'Dexametasona',
      'description': 'Descripción de Dexametasona',
      'price': '\$29.99',
    },
    {
      'imagePath': 'image/Ivermectina.png',
      'productName': 'Ivermectina',
      'description': 'Descripción de Ivermectina',
      'price': '\$29.99',
    },
  ];

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
                            color: const Color.fromARGB(255, 255, 255, 255),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          Expanded(
                            child: SearchBox(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            color: const Color.fromARGB(255, 255, 255, 255),
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
          const SizedBox(height: 0),
          Expanded(
            child: SingleChildScrollView(
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 615,
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
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: Productos2.length,
                            itemBuilder: (context, index) {
                              final nuevoProducto = Productos2[index];
                              return GestureDetector(
                                onTap: () {
                                  
                                },
                                child: ProductRectangleWithText(
                                  imagePath: nuevoProducto['imagePath']!,
                                  productName: nuevoProducto['productName']!,
                                  description: nuevoProducto['description']!,
                                  price: nuevoProducto['price']!,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 580,
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
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: productos.length,
                            itemBuilder: (context, index) {
                              final producto = productos[index];
                              return GestureDetector(
                                onTap: () {
                                 
                                },
                                child: ProductRectangleWithText(
                                  imagePath: producto['imagePath']!,
                                  productName: producto['productName']!,
                                  description: producto['description']!,
                                  price: producto['price']!,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
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
              color: const Color.fromARGB(255, 255, 255, 255),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.healing_sharp),
              color: const Color.fromARGB(255, 255, 255, 255),
              onPressed: () {
                
              },
            ),
          ],
        ),
      ),
    );
  }
}

class YellowRectangle extends StatelessWidget {
  final Widget child;

  YellowRectangle({required this.child});

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

class SearchBox extends StatefulWidget {
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _searchController = TextEditingController();
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
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: () {
              String searchTerm = _searchController.text;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Buscando: $searchTerm'),
                ),
              );
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

class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({required this.images});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndex = 0;
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
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
        onPageChanged: (index) {
          setState(() {});
        },
        itemBuilder: (context, index) {
          return RectangularImage(widget.images[index]);
        },
      ),
    );
  }
}

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

class IconRectangle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}

class ProductRectangle extends StatelessWidget {
  final String imagePath;
  final String productName;
  final String description;
  final String price;

  ProductRectangle({
    required this.imagePath,
    required this.productName,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 80.0,
              height: 80.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Precio: $price',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
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

class ProductSquare extends StatelessWidget {
  final String imagePath;

  const ProductSquare(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white, width: 2.0),
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

class ProductRectangleWithText extends StatelessWidget {
  final String imagePath;
  final String productName;
  final String description;
  final String price;

  const ProductRectangleWithText({
    required this.imagePath,
    required this.productName,
    required this.description,
    required this.price,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 80.0,
              height: 80.0,
            ),
          ),
          const SizedBox(width: 16.0),
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
                const SizedBox(height: 8.0),
                Text(
                  'Precio: $price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
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
