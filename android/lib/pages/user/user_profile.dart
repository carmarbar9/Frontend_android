import 'package:android/pages/login/elegirNegocio_page.dart';
import 'package:android/pages/planes/plans_page.dart';
import 'package:flutter/material.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/user/edit_profile_page.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/models/perfil.dart';
import 'package:android/services/service_perfil.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';

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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? username = SessionManager.username;

    if (username == null || username.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil de Usuario')),
        body: const Center(
          child: Text(
            'Error: No se encontró el username en la sesión.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: Image.asset('assets/logo.png', height: 62),
                ),
                Row(
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        try {
                          final productos =
                              await InventoryApiService.getProductosInventario();

                          final Map<int, List<Lote>> lotesPorProducto = {};
                          for (var producto in productos) {
                            final lotes =
                                await LoteProductoService.getLotesByProductoId(
                                  producto.id,
                                );
                            lotesPorProducto[producto.id] = lotes;
                          }

                          final notificaciones = NotificacionService()
                              .generarNotificacionesInventario(
                                productos,
                                lotesPorProducto,
                              );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => NotificacionPage(
                                    notificaciones: notificaciones,
                                  ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al cargar notificaciones: $e',
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    IconButton(
                      iconSize: 48,
                      icon: const Icon(
                        Icons.business_center,
                        color: Colors.black,
                      ),
                      tooltip: 'Cambiar negocio',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ElegirNegocioPage(
                                  user: SessionManager.currentUser!,
                                ),
                          ),
                        );
                      },
                    ),

                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'PERFIL',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontFamily: 'PermanentMarker',
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<UserProfile>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9B1D42),
                            Color(0xFFB12A50),
                            Color(0xFFD33E66),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'assets/employee3.png',
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'TitanOne',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          _buildDetailRow('Email', user.email),
                          _buildDetailRow('Usuario', user.user.username),
                          _buildDetailRow('Teléfono', user.numTelefono),
                          _buildDetailRow(
                            'Negocio',
                            SessionManager.negocioNombre ?? 'Sin negocio',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: _build3DPlansButton(),
                          ),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF9B1D42),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final updatedProfile = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                EditProfilePage(profile: user),
                                      ),
                                    );
                                    if (updatedProfile != null) {
                                      _refreshUserProfile();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Perfil actualizado'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 32,
                                    color: Color(0xFF9B1D42),
                                  ),
                                  label: const Text(
                                    'Editar',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'TitanOne',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF9B1D42),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () async {
                                    bool? confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Confirmar eliminación",
                                          ),
                                          content: const Text(
                                            "¿Estás seguro de que deseas eliminar tu cuenta? Se eliminarán todos los negocios asociados, productos y no hay vuelta atrás.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text("Cancelar"),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text(
                                                "Eliminar",
                                                style: TextStyle(
                                                  color: Color(0xFF9B1D42),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirmed == true) {
                                      bool success = await service
                                          .deleteUserProfile(user.user.id);
                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Perfil eliminado'),
                                          ),
                                        );
                                        SessionManager.clear();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const LoginPage(),
                                          ),
                                          (route) => false,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Error al eliminar el perfil',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 32,
                                    color: Color(0xFF9B1D42),
                                  ),
                                  label: const Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'TitanOne',
                                    ),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _build3DPlansButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) {
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlansPage()),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            elevation: 0,
          ),
          onPressed: null,
          icon: const Icon(
            Icons.card_membership,
            size: 32,
            color: Color(0xFF9B1D42),
          ),
          label: const Text(
            "Planes",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'TitanOne',
              color: Color(0xFF9B1D42),
            ),
          ),
        ),
      ),
    );
  }
}
