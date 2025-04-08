import 'package:flutter/material.dart';
import 'Sesion/Sesion.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions;
import 'firebase_options.dart';

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
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0.0, -100.0),
              child: Image.asset(
                'image/Pharma.png',
                width: 200.0,
                height: 200.0,
              ),
            ),
            const SizedBox(height: 50.0),
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              '¡Gracias por unirte! ¡Acceda o cree su cuenta y comience a ahorrar!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30.0),
            SizedBox(
              width: 220.0,
              height: 55.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SesionScreen()),
                  );
                },
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

