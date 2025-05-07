import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/common_widgets.dart';
import '../Modelos/doctor.dart';
import '../Widgets/formularioCita.dart';
import 'package:pharmacare/Screens/chatSeguimiento.dart'; // Ajusta la ruta si es distinta

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

  void _mostrarFormularioAgendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const FormularioAgendarCita(); // Usa el widget externo
      },
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(doctor.imageUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildIconTextRow(Icons.phone, doctor.phone),
                const SizedBox(height: 12),
                _buildIconTextRow(
                  Icons.email,
                  doctor.email,
                  isLink: true,
                  onTap: () => _launchEmail(doctor.email),
                ),
                const SizedBox(height: 12),
                _buildIconTextRow(
                  Icons.badge,
                  'Cédula profesional: ${doctor.license}',
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    doctor.description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.access_time, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.schedule,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _mostrarFormularioAgendar(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              backgroundColor: const Color(0xFF2F80ED),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Agendar cita',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildIconTextRow(Icons.location_on, doctor.address),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => _launchURL(doctor.mapUrl),
                    child: const Text(
                      'Ver en mapa',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildIconTextRow(
                  Icons.share,
                  doctor.socialLink,
                  isLink: true,
                  onTap: () => _launchURL(doctor.socialLink),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context)
                  .pushReplacementNamed('/'); // O tu pantalla de inicio
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatSeguimiento()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildIconTextRow(IconData icon, String text,
      {bool isLink = false, VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isLink ? Colors.blue : Colors.black,
                decoration:
                    isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
