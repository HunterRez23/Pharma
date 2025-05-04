import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/common_widgets.dart';
import '../Modelos/doctor.dart';

class DetallesMedico extends StatelessWidget {
  final Doctor doctor;
  const DetallesMedico({Key? key, required this.doctor}) : super(key: key);

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
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(doctor.imageUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  doctor.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doctor.phone,
                        style: const TextStyle(fontSize: 16),
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
                        onTap: () => _launchEmail(doctor.email),
                        child: Text(
                          doctor.email,
                          style: const TextStyle(
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
                  children: [
                    const Icon(Icons.badge, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cédula profesional: ${doctor.license}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  doctor.description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doctor.schedule,
                        style: const TextStyle(fontSize: 16),
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
                          Text(doctor.address),
                          GestureDetector(
                            onTap: () => _launchURL(doctor.mapUrl),
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
                      onTap: () => _launchURL(doctor.socialLink),
                      child: Text(
                        doctor.socialLink,
                        style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
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
            }
          },
        ),
      ),
    );
  }
}
