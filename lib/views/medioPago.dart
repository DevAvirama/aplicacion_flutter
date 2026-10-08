import 'package:flutter/material.dart';
import 'package:interfaz_final/theme/app_colors.dart';

class MedioPagoScreen extends StatefulWidget {
  const MedioPagoScreen({super.key});

  @override
  State<MedioPagoScreen> createState() => _MedioPagoScreenState();
}

class _MedioPagoScreenState extends State<MedioPagoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.payment, size: 80, color: AppColors.encabezado),
            const SizedBox(height: 16),
            const Text(
              'Medio de Pago',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.encabezado,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa los datos para confirmar la reserva',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.texto.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 30),

            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.campos,
                labelText: 'Nombre en la tarjeta',
                labelStyle: const TextStyle(color: AppColors.texto),
                prefixIcon: const Icon(
                  Icons.person,
                  color: AppColors.encabezado,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.campos,
                labelText: 'Número de tarjeta',
                labelStyle: const TextStyle(color: AppColors.texto),
                prefixIcon: const Icon(
                  Icons.credit_card,
                  color: AppColors.encabezado,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.campos,
                      labelText: 'MM/AA',
                      labelStyle: const TextStyle(color: AppColors.texto),
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.encabezado,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.campos,
                      labelText: 'CVV',
                      labelStyle: const TextStyle(color: AppColors.texto),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.encabezado,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.boton,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirmar Pago',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.encabezado,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
