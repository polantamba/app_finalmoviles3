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

  Future<void> _cargarVideo(String url) async {
    setState(() {
      _inicializado = false;
      _errorVideo = false;
    });

    try {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
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

  Future<void> _abrirTrailer(String url) async {
    final Uri uri = Uri.parse(url);
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "El emulador no cuenta con los códecs necesarios o el archivo de video de Dropbox es inaccesible.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
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
                  playedColor: Colors.redAccent,
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
            const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
          
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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
                onPressed: () => _abrirTrailer(_urlTrailer),
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