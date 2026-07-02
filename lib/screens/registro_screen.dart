import 'package:app_finalmoviles3/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Cuenta")),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: formulario(context),
          ),
        ),
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
        decoration: const InputDecoration(hintText: "Correo electrónico", prefixIcon: Icon(Icons.email, color: Colors.white54)),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: contrasenia,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: "Contraseña", prefixIcon: Icon(Icons.lock, color: Colors.white54)),
      ),
      const SizedBox(height: 40),
      FilledButton(
        onPressed: () => registro(context, correo, contrasenia),
        child: const Text("Registrarse", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

Future<void> registro(BuildContext context, correo, contrasenia) async {
  try {
    await supabase.auth.signUp(
      email: correo.text,
      password: contrasenia.text,
    );
    Navigator.pushNamed(context, "/login");
  } on AuthException catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text("Error de Registro", style: TextStyle(color: Colors.redAccent)),
        content: Text(e.message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}