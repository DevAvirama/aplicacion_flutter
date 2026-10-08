import 'package:flutter/material.dart';
import 'package:interfaz_final/controllers/alquiler_controller.dart';
import 'package:interfaz_final/theme/app_colors.dart';

class DetalleVehiculoScreen extends StatefulWidget {
  final String imageUrl;
  final String marca;
  final String modelo;
  final dynamic anio;
  final int disponibilidad;
  final int autoId;
  final dynamic precio;

  const DetalleVehiculoScreen({
    super.key,
    required this.imageUrl,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.disponibilidad,
    required this.autoId,
    this.precio,
  });

  @override
  State<DetalleVehiculoScreen> createState() => _DetalleVehiculoScreenState();
}

class _DetalleVehiculoScreenState extends State<DetalleVehiculoScreen> {
  bool disponible = true;
  bool cargando = false;
  final AlquilerService alquilerService = AlquilerService();

  @override
  void initState() {
    super.initState();
    disponible = widget.disponibilidad == 1;
  }

  void alquilarVehiculo() async {
    final String fechaInicio = DateTime.now().toUtc().toIso8601String();
    final String fechaFin = DateTime.now()
        .toUtc()
        .add(const Duration(days: 7))
        .toIso8601String();

    setState(() {
      cargando = true;
    });

    try {
      final response = await alquilerService.registrarAlquiler(
        widget.autoId,
        fechaInicio,
        fechaFin,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          disponible = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alquiler registrado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void confirmarAlquiler() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Alquiler'),
          content: const Text('¿Está seguro de que desea alquilar este vehículo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                alquilarVehiculo();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.encabezado,
        foregroundColor: Colors.white,
        title: Text('${widget.marca} ${widget.modelo}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.campos,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.imageUrl.toString(),
                    height: 160,
                    width: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://picsum.photos/330/200',
                        height: 160,
                        width: 260,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.marca} ${widget.modelo}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Año: ${widget.anio}',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.texto.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: disponible ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        disponible ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        disponible ? 'Disponible' : 'No disponible',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Precio: \$${widget.precio}/día',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.boton,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: disponible ? AppColors.boton : Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (!disponible || cargando) ? null : confirmarAlquiler,
                  icon: cargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.directions_car),
                  label: Text(
                    disponible ? 'Solicitar alquiler' : 'No disponible',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
