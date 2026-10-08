import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClienteService {
  final String baseUrl = 'https://api-restful-express.onrender.com/api/clientes';

  // POST /api/clientes/registro
  Future<http.Response> registrarCliente(
    String nombre,
    String correo,
    String numLic,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/registro');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'numLic': numLic,
        'password': password,
      }),
    );
    return response;
  }

  // POST /api/clientes/login
  Future<Map<String, dynamic>> loginCliente(
    String correo,
    String password,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Guardar el token en el dispositivo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token'] ?? '');
        await prefs.setString('user_email', correo);

        return {
          'success': true,
          'mensaje': responseData['mensaje'] ?? 'Inicio de sesión exitoso',
          'token': responseData['token'],
        };
      } else {
        return {
          'success': false,
          'mensaje': responseData['mensaje'] ?? 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión con el servidor: $e',
      };
    }
  }

  // GET /api/clientes/perfil (ruta protegida con token)
  Future<Map<String, dynamic>?> obtenerPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      final url = Uri.parse('$baseUrl/perfil');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

