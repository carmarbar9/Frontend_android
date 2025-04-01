// lib/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/edit_profile_page.dart';
import 'package:android/models/perfil.dart';
import 'package:android/services/service_perfil.dart';
import 'package:android/models/session_manager.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Se obtiene el username desde SessionManager
    final String? username = SessionManager.username;
    
    // Si no se encuentra el username, se muestra un error
    if (username == null || username.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil de Usuario'),
        ),
        body: const Center(
          child: Text(
            'Error: No se encontró el username en la sesión.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    
    final UserProfileService service = UserProfileService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png', height: 50),
          ),
        ),
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.redAccent, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: service.fetchUserProfileByUsername(username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Center(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 167, 45, 77),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 75,
                      backgroundImage: AssetImage('assets/user_avatar.png'),
                    ),
                    const SizedBox(height: 20),
                    // Título: Nombre bonito
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Datos
                    Text(
                      '${user.email}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Usuario: ${user.user.username}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tlf: ${user.numTelefono}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Negocio: ${SessionManager.negocioNombre ?? 'Sin negocio'}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botón Editar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                          ),
                          onPressed: () async {
                            // Navegar a la pantalla de edición
                            final updatedProfile = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfilePage(profile: user)),
                            );
                            if (updatedProfile != null) {
                              // Opcional: mostrar un mensaje o refrescar la pantalla
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Perfil actualizado')),
                              );
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar', style: TextStyle(fontSize: 20)),
                        ),
                        // Botón Eliminar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                          ),
                          onPressed: () async {
                            try {
                              await service.deleteUserProfile(user.id);
                              // Después de eliminar, se navega a la pantalla de login (o donde corresponda)
                              Navigator.pushReplacementNamed(context, '/login');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al eliminar perfil: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
