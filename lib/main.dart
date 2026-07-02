import 'package:app_finalmoviles3/screens/catalogo_screen.dart';
import 'package:app_finalmoviles3/screens/login_screen.dart';
import 'package:app_finalmoviles3/screens/registro_screen.dart';
import 'package:app_finalmoviles3/screens/reproductor_screen.dart';
import 'package:app_finalmoviles3/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bthiupwgfimuhwatsryn.supabase.co',
    publishableKey: 'sb_publishable_xIkKj-2R1NTmJv3YoRRrdQ__zAxsy0m',
  );
  runApp(const AppPeliculas());
}

final supabase = Supabase.instance.client;

class AppPeliculas extends StatelessWidget {
  const AppPeliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PolFlix',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: Colors.redAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.redAccent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF222222),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const WelcomeScreen(),
        "/login": (context) => const LoginScreen(),
        "/registro": (context) => const RegistroScreen(),
        "/catalogo": (context) => const CatalogoScreen(),
        "/reproductor": (context) => const ReproductorScreen(),
      },
    );
  }
}