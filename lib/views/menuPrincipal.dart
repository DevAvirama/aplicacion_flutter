import 'package:flutter/material.dart';
import 'package:interfaz_final/controllers/autos_controller.dart';
import 'package:interfaz_final/theme/app_colors.dart';
import 'package:interfaz_final/views/detalleVehiculo.dart';
import 'package:interfaz_final/views/menuDrawer.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _selectedIndex = 0;
  final AutosController autosController = AutosController();
  List<Map<String, dynamic>> listaDeAutos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarAutos();
  }

  void cargarAutos() async {
    try {
      final autos = await autosController.obtenerAutosDisponibles();
      if (!mounted) return;
      setState(() {
        listaDeAutos = autos;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar autos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuDrawerPerfil(),
      appBar: AppBar(
        title: const Text('Alquiler de Vehículos'),
        backgroundColor: AppColors.encabezado,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              cargarAutos();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: AppColors.texto),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppColors.encabezado),
                hintText: 'Buscar vehículo',
                hintStyle: TextStyle(color: AppColors.texto.withValues(alpha: 0.7)),
                filled: true,
                fillColor: AppColors.campos,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : listaDeAutos.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay vehículos disponibles',
                            style: TextStyle(fontSize: 16, color: AppColors.texto),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            cargarAutos();
                          },
                          child: ListView.builder(
                            itemCount: listaDeAutos.length,
                            itemBuilder: (BuildContext context, int index) {
                              final auto = listaDeAutos[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      auto['imageUrl'].toString(),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.network(
                                          'https://picsum.photos/330/200',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    '${auto['marca']} ${auto['modelo']}',
                                    style: const TextStyle(
                                      color: AppColors.texto,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Año: ${auto['anio']} - Precio: \$${auto['precio']}/día',
                                    style: const TextStyle(color: AppColors.texto),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: AppColors.boton,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetalleVehiculoScreen(
                                          imageUrl: auto['imageUrl'],
                                          marca: auto['marca'],
                                          modelo: auto['modelo'],
                                          anio: auto['anio'],
                                          disponibilidad:
                                              auto['disponibilidad'] is int
                                                  ? auto['disponibilidad']
                                                  : int.tryParse(auto['disponibilidad'].toString()) ?? 0,
                                          precio: auto['precio'],
                                          autoId: auto['id'] is int
                                              ? auto['id']
                                              : int.tryParse(auto['id'].toString()) ?? 0,
                                        ),
                                      ),
                                    ).then((_) {
                                      cargarAutos(); // recarga al volver del detalle
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.boton,
        unselectedItemColor: AppColors.texto,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Alquiler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuario'),
        ],
      ),
    );
  }
}
