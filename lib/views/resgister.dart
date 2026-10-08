import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:interfaz_final/controllers/cliente_controller.dart';
import 'package:interfaz_final/theme/app_colors.dart';
import 'package:interfaz_final/views/loginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _numLicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordControllervalida = TextEditingController();
  final ClienteService clienteService = ClienteService();
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _numLicController.dispose();
    _passwordController.dispose();
    _passwordControllervalida.dispose();
    super.dispose();
  }

  void limpiarCampos() {
    setState(() {
      _nombreController.clear();
      _correoController.clear();
      _numLicController.clear();
      _passwordController.clear();
      _passwordControllervalida.clear();
    });
  }

  void irLogin() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  void registrarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();
    final numLic = _numLicController.text.trim();
    final password = _passwordController.text;
    final passwordvalida = _passwordControllervalida.text;

    if (password != passwordvalida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final response = await clienteService.registrarCliente(
        nombre,
        correo,
        numLic,
        password,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Redirigiendo al login...'),
            backgroundColor: Colors.green,
          ),
        );
        limpiarCampos();
        irLogin();
      } else {
        String mensajeError = 'Error al registrar';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey('mensaje')) {
            mensajeError = body['mensaje'];
          }
        } catch (_) {
          mensajeError = response.body;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en la conexión con el servidor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.texto),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.campos,
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.texto),
        prefixIcon: Icon(icon, color: AppColors.encabezado),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.person_add, size: 80, color: AppColors.encabezado),
              const SizedBox(height: 16),
              const Text(
                "Empecemos",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.encabezado,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crear una nueva cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.texto.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 30),
              buildTextFormField(
                controller: _nombreController,
                label: "Nombre completo",
                icon: Icons.person,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: _correoController,
                label: "Correo electrónico",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  if (!valor.contains('@') || !valor.contains('.')) {
                    return 'Escribe un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: _numLicController,
                label: "Número de licencia",
                icon: Icons.badge,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'La licencia es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: _passwordController,
                label: "Contraseña",
                icon: Icons.lock,
                obscure: true,
                validator: (valor) {
                  if (valor == null || valor.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: _passwordControllervalida,
                label: "Confirmar contraseña",
                icon: Icons.lock,
                obscure: true,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (valor != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargando ? null : registrarCliente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.boton,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes una cuenta?',
                    style: TextStyle(color: AppColors.texto),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: AppColors.encabezado,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
