// lib/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/edit_profile_page.dart';
import 'package:android/pages/login/login_page.dart'; 
import 'package:android/models/perfil.dart';
import 'package:android/services/service_perfil.dart';
import 'package:android/models/session_manager.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserProfileService service = UserProfileService();
  Future<UserProfile>? _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _refreshUserProfile();
  }

  void _refreshUserProfile() {
    final String? username = SessionManager.username;
    if (username != null && username.isNotEmpty) {
      setState(() {
        _userProfileFuture = service.fetchUserProfileByUsername(username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? username = SessionManager.username;

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
          // Puedes agregar otras acciones aquí si lo deseas
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
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
                      backgroundImage: AssetImage('assets/employee3.png'),
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
                      ' ${user.email}',
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
                      '${SessionManager.negocioNombre ?? 'Sin negocio'}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 35),
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
                        // Navegar a la pantalla de edición y esperar el resultado
                        final updatedProfile = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(profile: user),
                          ),
                        );
                        if (updatedProfile != null) {
                          _refreshUserProfile();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil actualizado')),
                          );
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 20),
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
                        // Mostrar diálogo de confirmación con advertencia de eliminación irreversible
                        bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirmar eliminación"),
                              content: const Text(
                                "¿Estás seguro de que deseas eliminar tu cuenta? Se eliminarán todos los negocios asociados, productos y no hay vuelta atrás."
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmed == true) {
                          bool success = await service.deleteUserProfile(user.id);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perfil eliminado'))
                            );
                            // Limpiar datos de sesión si es necesario
                            SessionManager.clear();
                            // Redirigir al login
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al eliminar el perfil'))
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar', style: TextStyle(fontSize: 20)),
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
