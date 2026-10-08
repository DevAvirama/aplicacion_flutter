import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AutosController {
  final String baseUrl = 'https://api-restful-express.onrender.com/api/autos';

  // GET /api/autos — trae todos los vehículos
  Future<List<Map<String, dynamic>>> obtenerAutosDisponibles() async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map<Map<String, dynamic>>((auto) {
          final imagen = auto['imagen']?.toString().trim();

          return {
            'id': auto['id'],
            'marca': auto['marca'],
            'modelo': auto['modelo'],
            'anio': auto['anio'],
            'disponibilidad': auto['disponibilidad'],
            'imageUrl': (imagen != null &&
                    imagen.isNotEmpty &&
                    (imagen.startsWith('http://') ||
                        imagen.startsWith('https://')))
                ? imagen
                : 'https://picsum.photos/330/200',
            'precio': auto['valorAlquiler'],
          };
        }).toList();
      } else {
        throw Exception('Error al obtener vehículos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en obtenerAutosDisponibles: $e');
      return [];
    }
  }
}
