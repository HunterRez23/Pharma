import 'package:flutter/material.dart';
import '../Screens/PantallaPrincipal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SesionScreen extends StatefulWidget {
  @override
  _SesionScreenState createState() => _SesionScreenState();
}

class _SesionScreenState extends State<SesionScreen> {
  bool isLoginSelected = true; // True: iniciar sesión, False: crear cuenta

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController edadController = TextEditingController(); // Si deseas almacenar este dato en Firestore adicionalmente

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para iniciar sesión usando Firebase Authentication
  void signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      // Si la autenticación es exitosa, navega a PantallaPrincipal
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PantallaPrincipal()),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No se encontró usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else {
        message = 'Error: ${e.message}';
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  // Función para registrar un nuevo usuario usando Firebase Authentication
  void register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      // Opcional: Si deseas guardar datos adicionales (por ejemplo, edad) en Firestore, puedes hacerlo aquí.
      // Ejemplo:
      // await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
      //   "Edad": edadController.text.trim(),
      //   "Email": emailController.text.trim(),
      // });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Éxito'),
            content: Text('Usuario registrado correctamente'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PantallaPrincipal()),
                  );
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );

      // Limpiar los campos
      emailController.clear();
      passController.clear();
      edadController.clear();
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'El correo ya está en uso.';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil.';
      } else {
        message = 'Error: ${e.message}';
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  // Función para iniciar sesión con Google
  Future<void> signInWithGoogle() async {
    try {
      // Inicia el flujo de autenticación con Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // El usuario canceló el inicio de sesión

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crea las credenciales de Firebase usando el token de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autentica en Firebase con las credenciales de Google
      await _auth.signInWithCredential(credential);

      // Navega a PantallaPrincipal si la autenticación fue exitosa
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PantallaPrincipal()),
      );
    } catch (e) {
      // Manejar errores (por ejemplo, mostrar un diálogo de error)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error al iniciar sesión con Google: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0.0, -50.0),
                  child: Image.asset(
                    'image/Pharma.png',
                    width: 200.0,
                    height: 200.0,
                  ),
                ),
                SizedBox(height: 50.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSwitchButton('Iniciar sesión', isLoginSelected),
                      SizedBox(width: 2.0),
                      buildSwitchButton('Crear cuenta', !isLoginSelected),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                buildInputField('Correo', false, emailController),
                SizedBox(height: 10.0),
                buildInputField('Contraseña', true, passController),
                if (!isLoginSelected) SizedBox(height: 10.0),
                if (!isLoginSelected) buildInputField('Edad', false, edadController),
                SizedBox(height: 20.0),
                SizedBox(
                  width: 220.0,
                  height: 55.0,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLoginSelected) {
                        signIn();
                      } else {
                        register();
                      }
                    },
                    child: Text(
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
                SizedBox(height: 10.0),
                // Botón para iniciar sesión con Google
                SizedBox(
                  width: 220.0,
                  height: 55.0,
                  child: OutlinedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: Image.asset(
                      'image/google_logo.png', // Asegúrate de tener el logo de Google en assets y declarado en pubspec.yaml
                      height: 24.0,
                    ),
                    label: Text(
                      'Iniciar sesión',
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSwitchButton(String text, bool selected) {
    return InkWell(
      onTap: () {
        setState(() {
          isLoginSelected = text == 'Iniciar sesión';
          emailController.clear();
          passController.clear();
          edadController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 23.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.transparent, width: 1.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            color: selected ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, bool obscureText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );
  }
}
