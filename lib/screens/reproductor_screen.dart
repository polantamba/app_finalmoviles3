import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class ReproductorScreen extends StatefulWidget {
  const ReproductorScreen({super.key});

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<ReproductorScreen> {
  VideoPlayerController? _controller;
  bool _inicializado = false;
  bool _errorVideo = false;
  String _titulo = "";
  String _urlPelicula = "";
  String _urlTrailer = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado && _titulo.isEmpty) {
      final argumentos = ModalRoute.of(context)?.settings.arguments as Map?;
      if (argumentos != null) {
        _titulo = argumentos['titulo'] ?? 'Desconocido';
        _urlPelicula = argumentos['video_url'] ?? '';
        _urlTrailer = argumentos['trailer_url'] ?? '';
        
        _cargarVideo(_urlPelicula);
      }
    }
  }

  String _limpiarUrlDropbox(String url) {
    if (url.contains("dropbox.com")) {
      String urlProcesada = url.replaceAll("www.dropbox.com", "dl.dropboxusercontent.com");
      List<String> partes = urlProcesada.split('?');
      String urlBase = partes[0];
      
      if (partes.length > 1) {
        List<String> parametros = partes[1].split('&');
        String rlkey = "";
        
        for (var param in parametros) {
          if (param.startsWith("rlkey=")) {
            rlkey = param;
            break;
          }
        }
        
        if (rlkey.isNotEmpty) {
          return "$urlBase?$rlkey&raw=1";
        }
      }
      return "$urlBase?raw=1";
    }
    return url;
  }

  Future<void> _cargarVideo(String url) async {
    setState(() {
      _inicializado = false;
      _errorVideo = false;
    });

    try {
      _controller?.dispose();
      String urlProcesada = _limpiarUrlDropbox(url);
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(urlProcesada),
      );
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _inicializado = true;
        });
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorVideo = true;
        });
      }
    }
  }

  Future<void> _abrirEnlaceExterno(String url) async {
    final Uri uri = Uri.parse(_limpiarUrlDropbox(url));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_titulo, style: const TextStyle(fontSize: 18)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_errorVideo)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "Error de reproducción. Revisa los permisos de tu enlace de Dropbox.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 82, 255, 223)),
                      onPressed: () => _abrirEnlaceExterno(_urlPelicula),
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text("Reintentar externamente", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          else if (_inicializado && _controller != null) ...[
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color.fromARGB(255, 82, 255, 235),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 60,
                  color: Colors.white,
                  icon: Icon(
                    _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                    });
                  },
                ),
              ],
            ),
          ] else
            const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 82, 255, 220))),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 96, 221, 225),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                onPressed: () {
                  if (_urlPelicula.isNotEmpty) {
                    _cargarVideo(_urlPelicula);
                  }
                },
                icon: const Icon(Icons.movie, color: Colors.white),
                label: const Text("Ver Película", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                onPressed: () => _abrirEnlaceExterno(_urlTrailer),
                icon: const Icon(Icons.local_movies, color: Colors.white),
                label: const Text("Ver Tráiler (YouTube)", style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}