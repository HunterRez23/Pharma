class Doctor {
  final String name;
  final String specialty;
  final String imageUrl;
  final String phone;
  final String email;
  final String license;
  final String description;
  final String schedule;
  final String address;
  final String mapUrl;
  final String socialLink;

  const Doctor({
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.phone,
    required this.email,
    required this.license,
    required this.description,
    required this.schedule,
    required this.address,
    required this.mapUrl,
    required this.socialLink,
  });

 factory Doctor.fromMap(Map<String, dynamic> data) {
  final contact = data['contact'] ?? {};
  return Doctor(
    name: data['fullName'] ?? 'Sin nombre',
    specialty: (data['specialties'] as List<dynamic>).isNotEmpty ? data['specialties'][0] : 'General',
    imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
    phone: contact['phone'] ?? 'No disponible',
    email: contact['email'] ?? 'No disponible',
    license: contact['licenseNumber'] ?? 'No disponible',
    description: data['description'] ?? 'Sin descripción',
    schedule: data['schedule'] ?? 'Horario no disponible',
    address: data['address'] ?? 'Dirección no disponible',
    mapUrl: data['mapUrl'] ?? 'https://maps.google.com',
    socialLink: data['socialLink'] ?? 'https://example.com',
  );
}
}
