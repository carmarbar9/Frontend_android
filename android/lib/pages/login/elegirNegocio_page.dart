// lib/pages/login/elegirNegocio_page.dart
import 'package:flutter/material.dart';
import 'package:android/models/user.dart';
import 'package:android/models/negocio.dart';
import 'package:android/services/service_negocio.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/pages/negocio/create_negocio_page.dart';
import 'package:android/pages/negocio/edit_negocio_page.dart';
import 'package:android/pages/login/login_page.dart';

class ElegirNegocioPage extends StatefulWidget {
  final User user;

  const ElegirNegocioPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ElegirNegocioPage> createState() => _ElegirNegocioPageState();
}

class _ElegirNegocioPageState extends State<ElegirNegocioPage> {
  late Future<List<Negocio>> _negocios;

  @override
  void initState() {
    super.initState();
    _cargarNegocios();
  }

  // Cargar negocios del dueño logueado
  void _cargarNegocios() {
    print('DEBUG --- Token: ${SessionManager.token}');
    print('DEBUG --- UserID: ${SessionManager.userId}');
    print('DEBUG --- Username: ${SessionManager.username}');
    print('DEBUG --- Authority: ${SessionManager.authority}');

    _negocios = NegocioService.getMisNegocios();
  }

  void _seleccionarNegocio(Negocio negocio) {
    SessionManager.negocioId = negocio.id.toString();
    SessionManager.negocioNombre = negocio.name ?? 'Sin nombre';
    SessionManager.ciudad = negocio.ciudad ?? 'Sin ciudad';

    print('DEBUG --- Negocio seleccionado: ${negocio.id}');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _editarNegocio(Negocio negocio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNegocioPage(negocio: negocio),
      ),
    ).then((_) {
      // Recargar la lista al volver de editar
      setState(() {
        _cargarNegocios();
      });
    });
  }

  void _cerrarSesion() {
    SessionManager.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildCrearNegocioButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateNegocioPage()),
        ).then((_) {
          // Recargar la lista de negocios al volver
          setState(() {
            _cargarNegocios();
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFF9B1D42), Color(0xFFB12A50), Color(0xFFD33E66)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Crear Nuevo Negocio",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Esto quita la flecha
        title: const Text('Selecciona tu negocio'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 156, 28, 66),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),

      body: FutureBuilder<List<Negocio>>(
        future: _negocios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar negocios:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Si no hay negocios, muestra un mensaje y el botón de crear
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No tienes negocios registrados.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildCrearNegocioButton(),
                ],
              ),
            );
          } else {
            final negocios = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // Se muestra el botón de crear negocio en la parte superior
                _buildCrearNegocioButton(),
                ...negocios.map((negocio) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          negocio.name ?? 'Sin nombre',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          '${negocio.direccion ?? 'Sin dirección'}, ${negocio.ciudad ?? ''}\nCP: ${negocio.codigoPostal ?? ''}, ${negocio.pais ?? ''}',
                          style: const TextStyle(
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _editarNegocio(negocio),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        onTap: () => _seleccionarNegocio(negocio),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }
        },
      ),
    );
  }
}
