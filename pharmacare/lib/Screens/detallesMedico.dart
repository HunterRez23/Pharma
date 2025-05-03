import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/common_widgets.dart';

class DetallesMedico extends StatelessWidget {
  const DetallesMedico({Key? key}) : super(key: key);

  void _launchEmail(String email) async {
    final Uri params = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          showSearch: false,
          leadingIcon: Icons.arrow_back,
          onLeadingPressed: () => Navigator.of(context).pop(),
          onSearchSubmitted: (_) {},
          onFilterPressed: () {},
          onNotificationsPressed: () {},
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purpleAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dr. Nombre Apellido',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Especialidad',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Icon(Icons.phone, color: Colors.black),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '01-000-000',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _launchEmail('correoelectronico@email.com'),
                        child: const Text(
                          'correoelectronico@email.com',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.badge, color: Colors.black),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cédula profesional: 1234567',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Presentacion del medico Presentacion del medico Presentacion del medico '
                  'Presentacion del medico Presentacion del medico Presentacion del medico',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Icon(Icons.access_time, color: Colors.black),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lunes a Viernes: 9:00 a.m. – 6:00 p.m.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    // Acción de agendar
                  },
                  child: const Text('Agendar cita'),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Avenida 123, Ciudad, País'),
                          GestureDetector(
                            onTap: () => _launchURL('https://maps.google.com'),
                            child: const Text(
                              'Ver en mapa',
                              style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _launchURL('https://link.red.social.com'),
                      child: const Text(
                        'link.red.social.com',
                        style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 1,
          onTap: (index) {
            if (index != 1) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              //navegación a otras pantallas
            }
          },
        ),
      ),
    );
  }
}
