import 'package:flutter_test/flutter_test.dart';
import 'package:interfaz_final/main.dart';

void main() {
  testWidgets('App renders LoginScreen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    // Verificar que la pantalla de login muestra el título de bienvenida
    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
  });
}
