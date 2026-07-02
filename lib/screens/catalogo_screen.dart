import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "PolFlix",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Tendencias Ahora",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(child: listaPeliculas()),
        ],
      ),
    );
  }
}

Future<List<dynamic>> leerAPI() async {
  try {
    final respuesta = await http.get(Uri.parse('https://api.npoint.io/0d68b534bd1d5e58d02b'));
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body)['peliculas'] ?? [];
    }
    return [];
  } catch (e) {
    return [];
  }
}

Widget listaPeliculas() {
  return FutureBuilder(
    future: leerAPI(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text("Error al cargar el catálogo", style: TextStyle(color: Colors.white)));
      }

      final data = snapshot.data!;

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final pelicula = data[index];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                "/reproductor",
                arguments: {
                  'titulo': pelicula['titulo'],
                  'video_url': pelicula['video_url'],
                  'trailer_url': pelicula['trailer_url']
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 8, offset: const Offset(0, 5)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      pelicula['imagen'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF222222),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white38, size: 50),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.95), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          pelicula['titulo'] ?? 'Desconocido',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}