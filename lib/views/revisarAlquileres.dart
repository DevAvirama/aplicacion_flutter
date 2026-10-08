import 'package:flutter/material.dart';
import 'package:interfaz_final/controllers/alquiler_controller.dart';
import 'package:interfaz_final/theme/app_colors.dart';

class RevisarAlquileresScreen extends StatefulWidget {
  const RevisarAlquileresScreen({super.key});

  @override
  State<RevisarAlquileresScreen> createState() => _RevisarAlquileresScreenState();
}

class _RevisarAlquileresScreenState extends State<RevisarAlquileresScreen> {
  List<dynamic> alquileres = [];
  bool isLoading = true;
  final AlquilerService _alquilerService = AlquilerService();

  @override
  void initState() {
    super.initState();
    cargarAlquileres();
  }

  void cargarAlquileres() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _alquilerService.obtenerHistorial();
      if (!mounted) return;
      setState(() {
        alquileres = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar historial: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void confirmarDevolucion(int idAlquiler) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Devolver Vehículo'),
          content: const Text(
            '¿Deseas finalizar este alquiler y devolver el vehículo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final resp = await _alquilerService.devolverVehiculo(idAlquiler);
                  if (!mounted) return;
                  if (resp['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(resp['mensaje']),
                        backgroundColor: Colors.green,
                      ),
                    );
                    cargarAlquileres();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(resp['mensaje']),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al devolver vehículo: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Devolver'),
            ),
          ],
        );
      },
    );
  }

  String formatearFecha(dynamic fecha) {
    if (fecha == null) return '';
    try {
      final parsed = DateTime.parse(fecha.toString());
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    } catch (_) {
      return fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text('Mis Alquileres'),
        backgroundColor: AppColors.encabezado,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarAlquileres,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : alquileres.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes alquileres registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.texto,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    cargarAlquileres();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: alquileres.length,
                    itemBuilder: (context, index) {
                      final item = alquileres[index];
                      // Sequelize puede devolver Auto (con mayúscula) o auto (con minúscula)
                      final auto = item['Auto'] ?? item['auto'];
                      final bool esActivo = (item['estado']?.toString().toLowerCase() == 'activo');
                      final int? idAlquiler = item['id'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      auto?['imagen'] ?? 'https://picsum.photos/200',
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.network(
                                          'https://picsum.photos/200',
                                          width: 75,
                                          height: 75,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${auto?['marca'] ?? ''} ${auto?['modelo'] ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.texto,
                                          ),
                                        ),
                                        if (auto?['anio'] != null)
                                          Text(
                                            'Año: ${auto['anio']}',
                                            style: TextStyle(
                                              color: AppColors.texto
                                                  .withValues(alpha: 0.8),
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: esActivo
                                                ? Colors.green.shade100
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Estado: ${item['estado'] ?? 'desconocido'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: esActivo
                                                  ? Colors.green.shade800
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Inicio: ${formatearFecha(item['fechaInicio'])}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.texto,
                                        ),
                                      ),
                                      Text(
                                        'Fin: ${formatearFecha(item['fechaFin'])}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.texto,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (esActivo && idAlquiler != null)
                                    OutlinedButton(
                                      onPressed: () =>
                                          confirmarDevolucion(idAlquiler),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange.shade800,
                                        side: BorderSide(
                                          color: Colors.orange.shade800,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: const Text('Devolver'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
