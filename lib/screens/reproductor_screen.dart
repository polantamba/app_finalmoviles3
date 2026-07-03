import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _argumentosCargados = false;
  bool _mostrarControles = true;
  bool _esMute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argumentosCargados) {
      final argumentos = ModalRoute.of(context)?.settings.arguments as Map?;
      if (argumentos != null) {
        _titulo = argumentos['titulo'] ?? 'Desconocido';
        _urlPelicula = argumentos['video_url'] ?? '';
        _urlTrailer = argumentos['trailer_url'] ?? '';
        
        _argumentosCargados = true;
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

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _cargarVideo(String url) async {
    if (url.isEmpty) return;

    setState(() {
      _inicializado = false;
      _errorVideo = false;
    });

    try {
      if (_controller != null) {
        _controller!.removeListener(_videoListener);
        await _controller!.dispose();
        _controller = null;
      }
      
      String urlProcesada = _limpiarUrlDropbox(url);
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(urlProcesada),
      );
      
      await _controller!.initialize();
      _controller!.addListener(_videoListener);
      
      if (mounted) {
        setState(() {
          _inicializado = true;
        });
        _controller!.play();
        _ocultarControlesAutomaticamente();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorVideo = true;
          _inicializado = false;
        });
      }
    }
  }

  void _ocultarControlesAutomaticamente() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _mostrarControles = false;
        });
      }
    });
  }

  Future<void> _abrirEnlaceExterno(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(_limpiarUrlDropbox(url));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatearDuracion(Duration duration) {
    String dosDigitos(int n) => n.toString().padLeft(2, "0");
    String minutos = dosDigitos(duration.inMinutes.remainder(60));
    String segundos = dosDigitos(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${dosDigitos(duration.inHours)}:$minutos:$segundos";
    }
    return "$minutos:$segundos";
  }

  void _alternarPantallaCompleta() {
    // Nota: Esto es una simulación básica de orientación
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(_titulo, style: const TextStyle(fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _errorVideo
                  ? _buildErrorWidget()
                  : _inicializado && _controller != null
                      ? _buildPlayerWidget()
                      : const CircularProgressIndicator(color: Color.fromARGB(255, 82, 255, 220)),
            ),
          ),
          _buildBotonesAccion(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            icon: const Icon(Icons.open_in_new, color: Colors.black),
            label: const Text("Reintentar externamente", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _mostrarControles = !_mostrarControles;
          if (_mostrarControles) _ocultarControlesAutomaticamente();
        });
      },
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller!),
            // Capa oscura gradual tras los controles para que se lean bien
            AnimatedOpacity(
              opacity: _mostrarControles ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black45,
                child: _buildControlesMultimedia(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlesMultimedia() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Fila Superior: Volumen y Pantalla Completa
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(_esMute ? Icons.volume_off : Icons.volume_up, color: Colors.white),
              onPressed: () {
                setState(() {
                  _esMute = !_esMute;
                  _controller!.setVolume(_esMute ? 0.0 : 1.0);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: _alternarPantallaCompleta,
            ),
          ],
        ),

        // Centro: Play/Pause, Adelantar y Retrasar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 40,
              color: Colors.white,
              icon: const Icon(Icons.replay_10_rounded),
              onPressed: () {
                final nuevaPosicion = _controller!.value.position - const Duration(seconds: 10);
                _controller!.seekTo(nuevaPosicion < Duration.zero ? Duration.zero : nuevaPosicion);
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 60,
              color: const Color.fromARGB(255, 82, 255, 235),
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              ),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 40,
              color: Colors.white,
              icon: const Icon(Icons.forward_10_rounded),
              onPressed: () {
                final nuevaPosicion = _controller!.value.position + const Duration(seconds: 10);
                _controller!.seekTo(nuevaPosicion > _controller!.value.duration ? _controller!.value.duration : nuevaPosicion);
              },
            ),
          ],
        ),

        // Parte Inferior: Tiempos y Barra de Progreso deslizable
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatearDuracion(_controller!.value.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text(_formatearDuracion(_controller!.value.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true, // Esto permite arrastrar y tocar la barra para cambiar el minuto
                colors: const VideoProgressColors(
                  playedColor: Color.fromARGB(255, 82, 255, 235),
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBotonesAccion() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
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
            icon: const Icon(Icons.movie, color: Colors.black),
            label: const Text("Ver Película", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}