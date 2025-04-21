import 'package:flutter/material.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/models/proveedor.dart';
import 'package:android/models/dia_reparto.dart';
import 'package:android/services/service_proveedores.dart';
import 'package:android/pages/proveedores/provider_form_page.dart';
import 'package:android/pages/user/user_profile.dart';
import 'package:android/pages/login/login_page.dart';
import 'package:android/pages/home_page.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';
import 'package:android/pages/carrito/carritoProveedor_page.dart';
import 'package:android/pages/carrito/carritosPendientes_page.dart';



class ProvidersPage extends StatefulWidget {
  const ProvidersPage({Key? key}) : super(key: key);

  @override
  _ProvidersPageState createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  late Future<List<Proveedor>> _futureProveedores;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadProveedores();
  }

  void _loadProveedores() {
  final negocioIdStr = SessionManager.negocioId;
  if (negocioIdStr != null) {
    final negocioId = int.tryParse(negocioIdStr);
    if (negocioId != null) {
      _futureProveedores = ApiService.getProveedoresByNegocio(negocioId);
    } else {
      _futureProveedores = Future.value([]);
    }
  } else {
    _futureProveedores = Future.value([]);
  }
}


  void _navigateToAddProvider() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProviderFormPage()),
    );
    if (result == true) {
      setState(() {
        _searchQuery = null;
        _loadProveedores();
      });
    }
  }

  void _navigateToEditProvider(Proveedor proveedor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderFormPage(proveedor: proveedor),
      ),
    );
    if (result == true) {
      setState(() {
        _loadProveedores();
      });
    }
  }

  void _deleteProvider(Proveedor proveedor) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text(
            "¿Estás seguro de que deseas eliminar este proveedor?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text("Eliminar"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await ApiService.deleteProveedor(proveedor.id!);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Proveedor eliminado")));
        setState(() {
          _searchQuery = null;
          _loadProveedores();
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar proveedor: $error")),
        );
      }
    }
  }

  void _showSearchDialog() async {
    String? query;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Buscar Proveedor",
            style: TextStyle(
              color: Color(0xFF9B1D42),
              fontWeight: FontWeight.bold,
              fontFamily: 'TitanOne',
              fontSize: 18,
            ),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: "Ingresa nombre o teléfono",
              hintStyle: TextStyle(
                color: const Color(0xFF9B1D42).withOpacity(0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF9B1D42)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF9B1D42),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF9B1D42),
              fontWeight: FontWeight.bold,
            ),
            onChanged: (value) {
              query = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Color(0xFF9B1D42)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Buscar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    if ((query ?? '').trim().isNotEmpty) {
      setState(() {
        _searchQuery = query!.trim();
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _loadProveedores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Encabezado
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
                          final productos = await InventoryApiService.getProductosInventario();

                          final Map<int, List<Lote>> lotesPorProducto = {};
                          for (var producto in productos) {
                            final lotes = await LoteProductoService.getLotesByProductoId(producto.id);
                            lotesPorProducto[producto.id] = lotes;
                          }

                          final notificaciones = NotificacionService()
                              .generarNotificacionesInventario(productos, lotesPorProducto);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificacionPage(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error cargando notificaciones: $e')),
                          );
                        }
                      },
                    ),

                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.person, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfilePage(),
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

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'PROVEEDORES',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontFamily: 'PermanentMarker',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buscar y Añadir juntos
                  Row(
                    children: [
                      Expanded(
                        child: _build3DActionButton(
                          icon: Icons.search,
                          label: "Buscar",
                          onPressed: _showSearchDialog,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _build3DActionButton(
                          icon: Icons.add,
                          label: "Añadir",
                          onPressed: _navigateToAddProvider,
                        ),
                      ),
                    ],
                  ),

                  if (_searchQuery != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Chip(
                        backgroundColor: const Color(
                          0xFF9B1D42,
                        ).withOpacity(0.2),
                        label: Text(
                          "Búsqueda: $_searchQuery",
                          style: const TextStyle(
                            color: Color(0xFF9B1D42),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        deleteIcon: const Icon(
                          Icons.close,
                          color: Color(0xFF9B1D42),
                        ),
                        onDeleted: _clearSearch,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Lista de proveedores
                  Expanded(
                    child: FutureBuilder<List<Proveedor>>(
                      future: _futureProveedores,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No hay proveedores"),
                          );
                        } else {
                          List<Proveedor> proveedores = snapshot.data!;
                          if (_searchQuery != null &&
                              _searchQuery!.isNotEmpty) {
                            final query = _searchQuery!;
                            if (RegExp(r'^\d+$').hasMatch(query)) {
                              proveedores =
                                  proveedores
                                      .where(
                                        (p) =>
                                            p.telefono != null &&
                                            p.telefono!.startsWith(query),
                                      )
                                      .toList();
                            } else {
                              proveedores =
                                  proveedores
                                      .where(
                                        (p) =>
                                            p.name != null &&
                                            p.name!.toLowerCase().startsWith(
                                              query.toLowerCase(),
                                            ),
                                      )
                                      .toList();
                            }
                          }
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
          ),
        ],
      ),
    );
  }

  // Botón reutilizable con estilo 3D (para Buscar y Añadir)
  Widget _build3DActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(3, 3)),
          BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-3, -3)),
        ],
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF9B1D42),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF9B1D42), width: 2),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 30, color: const Color(0xFF9B1D42)),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'TitanOne',
            color: Color(0xFF9B1D42),
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3,
                color: Colors.black12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tarjeta del proveedor
  Widget _buildProviderCard(Proveedor proveedor) {
    return FutureBuilder<List<DiaReparto>>(
      future: ApiService.getDiasRepartoByProveedor(proveedor.id!),
      builder: (context, snapshot) {
        List<Widget> diaWidgets = [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          diaWidgets.add(
            const Text(
              "Cargando días...",
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          diaWidgets.add(
            const Text(
              "Error al cargar días",
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          diaWidgets =
              (snapshot.data! as List<DiaReparto>)
                  .map<Widget>(
                    (DiaReparto dia) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${dia.diaSemana}${dia.descripcion != null && dia.descripcion!.isNotEmpty ? " (${dia.descripcion})" : ""}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList();
        } else {
          diaWidgets.add(
            const Text(
              "Sin días de reparto",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9B1D42), Color(0xFFB12A50), Color(0xFFD33E66)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TitanOne',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Email: ${proveedor.email ?? ''}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "Teléfono: ${proveedor.telefono ?? ''}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "Dirección: ${proveedor.direccion ?? ''}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                "Días de Reparto:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...diaWidgets,
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildFlatWhiteButton(
                      icon: Icon(Icons.edit, size: 32, color: Color(0xFF9B1D42)),
                      label: "Editar",
                      onPressed: () => _navigateToEditProvider(proveedor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFlatWhiteButton(
                      icon: Icon(Icons.delete, size: 32, color: Color(0xFF9B1D42)),
                      label: "Eliminar",
                      onPressed: () => _deleteProvider(proveedor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _buildFlatWhiteButton(
                  icon: Icon(Icons.shopping_cart, size: 30, color: Color(0xFF9B1D42)), // puedes ajustar el tamaño

                  label: "Ver Carrito",
                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarritoProveedorPage(proveedor: proveedor),
                    ),
                  );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _buildFlatWhiteButton(
                  icon: Icon(Icons.pending_actions, size: 30, color: Color(0xFF9B1D42)),
                  label: "Ver pendientes",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarritosPendientesPage(proveedor: proveedor),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildFlatWhiteButton({
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(
        label,
        style: const TextStyle(color: Color(0xFF9B1D42), fontSize: 18, fontFamily: 'TitanOne'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9B1D42),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    );
  }
}
