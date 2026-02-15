import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/datasources/chat_socket_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/presentation/providers/chat_provider.dart';

import 'core/router/app_router.dart';

/// Punto de entrada principal de la aplicación.
void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de ejecutar código asíncrono.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Servicios Core y Dependencias Externas.
  final sharedPreferences = await SharedPreferences.getInstance();
  final dioClient = DioClient();

  // --- Inyección de Dependencias (DI) Manual ---

  // 1. Módulo de Autenticación (Auth)
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient: dioClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    sharedPreferences: sharedPreferences,
  );

  // 2. Módulo de Chat
  final chatRemoteDataSource = ChatRemoteDataSourceImpl(dioClient: dioClient);
  final chatSocketDataSource = ChatSocketDataSourceImpl();
  final chatRepository = ChatRepositoryImpl(
    remoteDataSource: chatRemoteDataSource,
    socketDataSource: chatSocketDataSource,
  );

  // Ejecución de la App con MultiProvider para estado global.
  runApp(
    MultiProvider(
      providers: [
        // Provider para Autenticación.
        // Se verifica el estado de la sesión nada más crear el provider.
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(authRepository: authRepository)..checkAuthStatus(),
        ),
        // Provider para la lógica del Chat.
        ChangeNotifierProvider(
          create: (_) => ChatProvider(chatRepository: chatRepository),
        ),
      ],
      child: MyApp(),
    ),
  );
}

/// Widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Configuración de rutas centralizada en AppRouter.
      routerConfig: AppRouter.createRouter(context),
    );
  }
}
