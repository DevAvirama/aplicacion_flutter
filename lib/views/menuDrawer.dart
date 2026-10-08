import 'package:flutter/material.dart';
import 'package:interfaz_final/controllers/cliente_controller.dart';
import 'package:interfaz_final/theme/app_colors.dart';
import 'package:interfaz_final/views/loginScreen.dart';
import 'package:interfaz_final/views/revisarAlquileres.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDrawerPerfil extends StatefulWidget {
  const MenuDrawerPerfil({super.key});

  @override
  State<MenuDrawerPerfil> createState() => _MenuDrawerPerfilState();
}

class _MenuDrawerPerfilState extends State<MenuDrawerPerfil> {
  final ClienteService _clienteService = ClienteService();
  String _nombre = "Cargando...";
  String _correo = "";
  String _numLic = "";
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  void _cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final emailGuardado = prefs.getString('user_email') ?? '';

    final perfil = await _clienteService.obtenerPerfil();
    if (!mounted) return;

    if (perfil != null) {
      setState(() {
        _nombre = perfil['nombre'] ?? 'Usuario';
        _correo = perfil['correo'] ?? emailGuardado;
        _numLic = perfil['numLic'] ?? '';
        _cargando = false;
      });
    } else {
      setState(() {
        _nombre = 'Usuario';
        _correo = emailGuardado.isNotEmpty ? emailGuardado : 'correo@ejemplo.com';
        _numLic = 'No disponible';
        _cargando = false;
      });
    }
  }

  void _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_email');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: AppColors.encabezado,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/330/200',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: _cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Column(
                      children: [
                        Text(
                          _nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _correo,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.badge, color: AppColors.encabezado),
              title: const Text("Número de licencia"),
              subtitle: Text(_numLic.isNotEmpty ? _numLic : "No registrada"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.boton),
              title: const Text("Revisar Alquileres"),
              onTap: () {
                Navigator.of(context).pop(); // Cerrar drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RevisarAlquileresScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red),
              ),
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }
}
