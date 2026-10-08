import 'package:flutter/material.dart';
import 'package:interfaz_final/theme/app_colors.dart';

Widget buildTextField({
  required String label,
  required IconData icon,
  bool obscure = false,
}) {
  return TextField(
    obscureText: obscure,
    style: TextStyle(color: AppColors.texto),
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.campos,
      labelText: label,
      labelStyle: TextStyle(color: AppColors.texto),
      prefixIcon: Icon(icon, color: AppColors.encabezado),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
