import 'package:flutter/material.dart';
import 'package:android/models/producto_venta.dart';
import 'package:android/services/service_carta.dart';
import 'package:android/pages/carta/editProductoVenta_page.dart';
import 'package:android/models/categoria.dart';

class ProductosPorCategoriaPage extends StatefulWidget {
  final Categoria categoria;

  const ProductosPorCategoriaPage({super.key, required this.categoria});

  @override
  State<ProductosPorCategoriaPage> createState() => _ProductosPorCategoriaPageState();
}

class _ProductosPorCategoriaPageState extends State<ProductosPorCategoriaPage> {
  late Future<List<ProductoVenta>> _futureProductos;

  @override
  void initState() {
    super.initState();
    _futureProductos = ProductoVentaService().getProductosByCategoriaNombre(widget.categoria.name);
  }

  void _refrescar() {
    setState(() {
      _futureProductos = ProductoVentaService().getProductosByCategoriaNombre(widget.categoria.name);
    });
  }

  void _borrarProducto(int id) async {
    try {
      await ProductoVentaService().deleteProductoVenta(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado con éxito')),
      );
      _refrescar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: $e')),
      );
    }
  }

  void _editarProducto(ProductoVenta producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductoVentaPage(producto: producto),
      ),
    );

    if (result == true) {
      _refrescar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: SizedBox(
            height: 120,
            width: 120,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Productos de ${widget.categoria.name}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nuevoProducto = ProductoVenta(
            id: 0,
            name: '',
            precioVenta: 0.0,
            categoria: widget.categoria,
          );

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProductoVentaPage(producto: nuevoProducto, isCreating: true),
            ),
          );

          if (result == true) _refrescar();
        },
        backgroundColor: const Color.fromARGB(255, 167, 45, 77),
        icon: const Icon(Icons.add),
        label: const Text('Crear nuevo plato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<ProductoVenta>>(
          future: _futureProductos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay productos en esta categoría"));
            }

            final productos = snapshot.data!;
            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 167, 45, 77),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      p.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${p.precioVenta.toStringAsFixed(2)} €",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editarProducto(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _borrarProducto(p.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
