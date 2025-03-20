import 'package:flutter/material.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/services/api_service.dart';
import 'package:android/pages/proveedores/provider_form_page.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({Key? key}) : super(key: key);

  @override
  _ProvidersPageState createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  late Future<List<Proveedor>> _futureProveedores;

  @override
  void initState() {
    super.initState();
    _loadProveedores();
  }

  void _loadProveedores() {
    _futureProveedores = ApiService.getProveedores();
  }

  // Navega a la pantalla para añadir un nuevo proveedor
  void _navigateToAddProvider() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProviderFormPage()),
    );
    if (result == true) {
      setState(() {
        _loadProveedores();
      });
    }
  }

  // Navega a la pantalla para editar un proveedor existente
  void _navigateToEditProvider(Proveedor proveedor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProviderFormPage(proveedor: proveedor)),
    );
    if (result == true) {
      setState(() {
        _loadProveedores();
      });
    }
  }

  // Función para eliminar un proveedor, con confirmación previa
  void _deleteProvider(Proveedor proveedor) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar este proveedor?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            ElevatedButton(
              child: const Text("Eliminar"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await ApiService.deleteProveedor(proveedor.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Proveedor eliminado")),
        );
        setState(() {
          _loadProveedores();
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar proveedor: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/logo.png',
            height: 60,
            width: 60,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Aquí podrías agregar navegación al perfil de usuario
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'PROVEEDORES',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Aquí podrías implementar lógica de búsqueda
                  },
                  child: const Text(
                    'Buscar',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Aquí podrías implementar lógica de filtrado
                  },
                  child: const Text(
                    'Filtrar',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _navigateToAddProvider,
              icon: const Icon(Icons.add, size: 30),
              label: const Text(
                "Añadir",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Proveedor>>(
                future: _futureProveedores,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay proveedores"));
                  } else {
                    final proveedores = snapshot.data!;
                    return ListView.builder(
                      itemCount: proveedores.length,
                      itemBuilder: (context, index) {
                        final proveedor = proveedores[index];
                        return _buildProviderCard(proveedor);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(Proveedor proveedor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 151, 48, 66),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            proveedor.name ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Email: ${proveedor.email ?? ''}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Teléfono: ${proveedor.telefono ?? ''}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Dirección: ${proveedor.direccion ?? ''}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          // Primera fila: Editar y Eliminar ocupan cada uno el 50% del ancho
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _navigateToEditProvider(proveedor);
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text("Editar"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _deleteProvider(proveedor);
                  },
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text("Eliminar"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Botón "Ver Carrito" ocupa todo el ancho
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Lógica para "Ver Carrito" u otra acción
              },
              icon: const Icon(Icons.shopping_cart, size: 20),
              label: const Text("Ver Carrito"),
            ),
          ),
        ],
      ),
    );
  }
}
