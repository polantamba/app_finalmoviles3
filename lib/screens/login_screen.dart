import 'package:app_finalmoviles3/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/fondo3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                width: double.infinity,
                child: formulario(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget formulario(BuildContext context) {
  TextEditingController correo = TextEditingController();
  TextEditingController contrasenia = TextEditingController();

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: correo,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Correo electrónico", 
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.email, color: Color(0xFF00F5D4))
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: contrasenia,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Contraseña", 
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.lock, color: Color(0xFF00F5D4))
        ),
      ),
      const SizedBox(height: 40),
      // Botón con color turquesa
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF00F5D4), // Color Turquesa
          foregroundColor: Colors.black,             // Texto negro para contraste
        ),
        onPressed: () => login(context, correo, contrasenia),
        child: const Text("Entrar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

Future<void> login(BuildContext context, correo, contrasenia) async {
  try {
    await supabase.auth.signInWithPassword(
      email: correo.text,
      password: contrasenia.text,
    );
    Navigator.pushNamed(context, "/catalogo");
  } on AuthException catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Error", style: TextStyle(color: Color(0xFF00F5D4))),
        content: Text(e.message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}