import 'package:flutter/material.dart';
import 'package:android/models/user.dart';
import 'package:android/models/negocio.dart';
import 'package:android/services/service_negocio.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/pages/home_page.dart';

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
    final int? userId = widget.user.id;
    if (userId != null) {
      _negocios = NegocioService.getNegociosByDuenoId(userId);
    } else {
      _negocios = Future.error('ID de usuario no válido');
    }
  }

  void _seleccionarNegocio(Negocio negocio) {
    SessionManager.negocioId = negocio.id.toString();
    SessionManager.negocioNombre = negocio.name ?? '';
    SessionManager.ciudad = negocio.ciudad ?? '';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _volverAtras() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu negocio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _volverAtras,
        ),
      ),
      body: FutureBuilder<List<Negocio>>(
        future: _negocios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar negocios:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes negocios registrados.'));
          } else {
            final negocios = snapshot.data!;
            return ListView.builder(
              itemCount: negocios.length,
              itemBuilder: (context, index) {
                final negocio = negocios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      negocio.name ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${negocio.direccion ?? 'Sin dirección'}, ${negocio.ciudad ?? ''}\nCP: ${negocio.codigoPostal ?? ''}, ${negocio.pais ?? ''}',
                      style: const TextStyle(height: 1.4),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _seleccionarNegocio(negocio),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
