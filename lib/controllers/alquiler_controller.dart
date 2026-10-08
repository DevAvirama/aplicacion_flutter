import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlquilerService {
  // Ruta base del backend en Render
  final String baseUrl = 'https://api-restful-express.onrender.com/api/alquileres';

  // Arma la cabecera con el token para rutas protegidas
  Future<Map<String, String>> _headersConToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // POST /api/alquileres — registrar un alquiler
  Future<Map<String, dynamic>> registrarAlquiler(
    int autoId,
    String fechaInicio,
    String fechaFin,
  ) async {
    try {
      final url = Uri.parse(baseUrl);
      final headers = await _headersConToken();
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'autoId': autoId,
              'fechaInicio': fechaInicio,
              'fechaFin': fechaFin,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map && data.containsKey('mensaje') && !data.containsKey('alquiler') && !data.containsKey('id')) {
          // Si el backend devolvió mensaje informativo de error con 200
          return {'success': true, 'message': data['mensaje'], 'data': data};
        }
        return {'success': true, 'data': data, 'message': data['mensaje'] ?? 'Alquiler registrado con éxito'};
      } else {
        return {
          'success': false,
          'message': data['mensaje'] ?? 'Error al registrar el alquiler',
        };
      }
    } catch (e) {
      debugPrint('Error en registrarAlquiler: $e');
      return {
        'success': false,
        'message': 'Error de conexión con el servidor: $e',
      };
    }
  }

  // GET /api/alquileres/mis-alquileres (o /historial) — historial del cliente autenticado
  Future<List<dynamic>> obtenerHistorial() async {
    try {
      final headers = await _headersConToken();
      // El backend del usuario usa /mis-alquileres
      Uri url = Uri.parse('$baseUrl/mis-alquileres');
      http.Response response = await http.get(url, headers: headers);

      // Si diera 404 por variación de ruta, probar con /historial
      if (response.statusCode == 404) {
        url = Uri.parse('https://api-restful-express.onrender.com/api/alquiler/historial');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar alquileres: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en obtenerHistorial: $e');
      rethrow;
    }
  }

  // PUT /api/alquileres/:id/finalizar (o /devolver/:id) — devolver/finalizar alquiler
  Future<Map<String, dynamic>> devolverVehiculo(int idAlquiler) async {
    try {
      final headers = await _headersConToken();
      Uri url = Uri.parse('$baseUrl/$idAlquiler/finalizar');
      http.Response response = await http.put(url, headers: headers);

      if (response.statusCode == 404) {
        url = Uri.parse('https://api-restful-express.onrender.com/api/alquiler/devolver/$idAlquiler');
        response = await http.put(url, headers: headers);
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? 'Alquiler finalizado exitosamente',
        };
      } else {
        return {
          'success': false,
          'mensaje': data['mensaje'] ?? 'Error al devolver vehículo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al devolver vehículo: $e',
      };
    }
  }
}
