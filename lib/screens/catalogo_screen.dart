import 'package:app_finalmoviles3/main.dart';
import 'package:flutter/material.dart';


class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Películas Destacadas", style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: listaPeliculas(),
    );
  }
}

Future<List<dynamic>> leerPeliculas() async {
  final data = await supabase.from('peliculas').select();
  return data;
}

Widget listaPeliculas() {
  return FutureBuilder(
    future: leerPeliculas(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
      } else if (snapshot.hasError) {
        return const Center(child: Text("Error al cargar el catálogo", style: TextStyle(color: Colors.white)));
      } else if (snapshot.hasData) {
        final data = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final pelicula = data[index];

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/reproductor",
                  arguments: {'titulo': pelicula['titulo'], 'video_url': pelicula['video_url']},
                );
              },
              child: Container(
                height: 220,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(pelicula['imagen']),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pelicula['titulo'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        pelicula['descripcion'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        return const Center(child: Text("No hay películas disponibles"));
      }
    },
  );
}