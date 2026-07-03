import 'dart:io';
import 'package:app_finalmoviles3/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Nueva Cuenta", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00F5D4)),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/fondo2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.8),
                  const Color(0xFF141414),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 100, bottom: 20),
                width: double.infinity,
                child: const FormularioRegistro(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({super.key});

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();
  final TextEditingController nick = TextEditingController();
  final TextEditingController edad = TextEditingController();

  bool _isLoading = false;
  File? _imagenPerfil;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    correo.dispose();
    contrasenia.dispose();
    nick.dispose();
    edad.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (imagenSeleccionada != null) {
        setState(() {
          _imagenPerfil = File(imagenSeleccionada.path);
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF00F5D4)),
                title: const Text('Elegir de Galería', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF00F5D4)),
                title: const Text('Tomar Foto', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> registro() async {
    setState(() => _isLoading = true);
    
    try {
      await supabase.auth.signUp(
        email: correo.text.trim(),
        password: contrasenia.text.trim(),
        data: {
          'nick': nick.text.trim(),
          'edad': int.tryParse(edad.text.trim()) ?? 0,
        }
      );
      
      if (mounted) Navigator.pushReplacementNamed(context, "/login");
      
    } on AuthException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF222222),
            title: const Text("Error de Registro", style: TextStyle(color: Colors.redAccent)),
            content: Text(e.message, style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _mostrarOpcionesImagen,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white12,
                backgroundImage: _imagenPerfil != null ? FileImage(_imagenPerfil!) : null,
                child: _imagenPerfil == null
                    ? const Icon(Icons.person, size: 50, color: Color(0xFF00F5D4))
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF00F5D4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        TextField(
          controller: nick,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nickname", 
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF00F5D4)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F5D4))),
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: edad,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Edad", 
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.cake_outlined, color: Color(0xFF00F5D4)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F5D4))),
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: correo,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Correo electrónico", 
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF00F5D4)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F5D4))),
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
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00F5D4)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F5D4))),
          ),
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00F5D4),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isLoading ? null : registro,
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text("Registrarse", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 15),

        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
          child: const Text(
            "¿Ya tienes cuenta? Inicia sesión", 
            style: TextStyle(color: Colors.white70, fontSize: 14)
          ),
        ),
      ],
    );
  }
}