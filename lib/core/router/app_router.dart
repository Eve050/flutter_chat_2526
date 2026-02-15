import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/home_screen.dart';

/// Clase encargada de definir y centralizar la configuración de rutas de la aplicación.
/// Utiliza el paquete [GoRouter] para gestionar la navegación de forma declarativa.
class AppRouter {
  /// Crea y retorna la configuración del router.
  ///
  /// Recibe [BuildContext] para poder acceder a los Providers necesarios
  /// (como [AuthProvider]) y realizar validaciones de redirección.
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      // Ruta inicial de la aplicación.
      initialLocation: '/',

      routes: [
        // Pantalla de Login (Ruta raíz).
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const LoginScreen();
          },
          // Lógica de redirección basada en el estado de autenticación.
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );

            // Si el usuario ya está autenticado, redirigir al Home.
            if (authProvider.user != null) {
              return '/home';
            }
            return null;
          },
        ),

        // Pantalla Principal (Home).
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

        // Pantalla de Chat Individual.
        // Recibe el parámetro [userId] en la URL.
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) {
            final userIdStr = state.pathParameters['userId'];
            final userId = int.parse(userIdStr!);
            return ChatScreen(targetUserId: userId);
          },
        ),
      ],
      // Opcional: Se puede agregar 'refreshListenable' para reaccionar
      // automáticamente a cambios en el AuthProvider si se desea.
    );
  }
}
