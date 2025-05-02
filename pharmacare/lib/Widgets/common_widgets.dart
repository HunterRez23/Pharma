// lib/widgets/common_widgets.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Barra superior configurable: buscador con 2 botones o título con back
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Si true, muestra buscador; si false, muestra título
  final bool showSearch;
  /// Título de la pantalla (usado cuando showSearch == false)
  final String? title;

  /// Icono izquierdo (por defecto menú o back según [showSearch])
  final IconData? leadingIcon;
  /// Acción al pulsar icono izquierdo
  final VoidCallback onLeadingPressed;

  /// Callback al enviar búsqueda (requerido si showSearch == true)
  final ValueChanged<String>? onSearchSubmitted;
  /// Acción del botón de filtro (opcional, si showSearch)
  final VoidCallback? onFilterPressed;
  /// Acción del botón de notificaciones (opcional, si showSearch)
  final VoidCallback? onNotificationsPressed;

  const CustomAppBar({
    Key? key,
    this.showSearch = true,
    this.title,
    this.leadingIcon,
    required this.onLeadingPressed,
    this.onSearchSubmitted,
    this.onFilterPressed,
    this.onNotificationsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          leadingIcon ?? (showSearch ? Icons.menu : Icons.arrow_back),
          color: Colors.white,
        ),
        onPressed: onLeadingPressed,
      ),
      title: showSearch
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            )
          : Text(
              title ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
      actions: showSearch
          ? <Widget>[ if (onFilterPressed != null)
            
              if (onNotificationsPressed != null)
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: onNotificationsPressed,
                ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Barra inferior reutilizable
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.local_pharmacy),
          label: 'Farmacias',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
      ],
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    );
  }
}

/// Carrusel de imágenes local
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  const ImageCarousel({Key? key, required this.images}) : super(key: key);

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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _currentIndex = (_currentIndex + 1) % widget.images.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
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
      height: 150,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) => RectangularImage(widget.images[index]),
      ),
    );
  }
}

/// Imagen rectangular para carrusel
class RectangularImage extends StatelessWidget {
  final String imagePath;
  const RectangularImage(this.imagePath, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 2),
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
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
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
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.blue,
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
            child: Container(
              width: 80.0,
              height: 80.0,
              color: Colors.grey[300],
              child: Image.network(
                imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/80',
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
