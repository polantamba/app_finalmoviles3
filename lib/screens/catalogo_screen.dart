  import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "MOVIESTREAM",
          style: TextStyle(
            color: Color(0xFF00F5D4), // Color turquesa
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Tendencias Ahora",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(child: ListaPeliculas()),
        ],
      ),
    );
  }
}

class ListaPeliculas extends StatelessWidget {
  const ListaPeliculas({super.key});

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

  void _mostrarDetalles(BuildContext context, dynamic pelicula) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal ocupe más espacio si es necesario
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20, // Respeta el safe area del celular
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pequeña barra superior del modal
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Imagen de portada
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  pelicula['imagen'] ?? '',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.black45,
                    child: const Icon(Icons.broken_image, color: Colors.white38, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              Text(
                pelicula['titulo'] ?? 'Desconocido',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00F5D4),
                ),
              ),
              const SizedBox(height: 10),
              
              // Descripción
              Text(
                pelicula['descripcion'] ?? 'Sin descripción disponible.',
                style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 30),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00F5D4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Cierra el modal
                        Navigator.pushNamed(
                          context,
                          "/reproductor",
                          arguments: {
                            'titulo': pelicula['titulo'],
                            'video_url': pelicula['video_url'],
                            // Uso 'tracker_url' como respaldo por un typo en el JSON de Titanic
                            'trailer_url': pelicula['trailer_url'] ?? pelicula['tracker_url'],
                          },
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text("Ver Película", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00F5D4),
                        side: const BorderSide(color: Color(0xFF00F5D4), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Cierra el modal
                        // Aquí puedes añadir la lógica específica para abrir el tráiler si lo manejas en otra vista
                      },
                      icon: const Icon(Icons.movie_creation_outlined),
                      label: const Text("Ver Tráiler", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: leerAPI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)));
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
              onTap: () => _mostrarDetalles(context, pelicula), // Abre el modal aquí
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 5)),
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
                              colors: [Colors.black.withValues(alpha: 0.95), Colors.transparent],
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
}