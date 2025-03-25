import 'package:android/models/producto_inventario.dart';
import 'package:android/models/categoria.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/services/service_inventory.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class ItemDetailsPage extends StatefulWidget {
  final String itemName;
  final String category; // Este valor podría ser utilizado para iconos o navegación

  const ItemDetailsPage({super.key, required this.itemName, required this.category});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late Future<ProductoInventario?> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = InventoryApiService.getProductoInventarioByName(widget.itemName);
  }

  // Mapa de íconos (puedes actualizarlo según tus necesidades)
  final Map<String, IconData> categoryIcons = {
    'Verduras': FontAwesomeIcons.carrot,
    'Carnes': LineIcons.drumstickWithBiteTakenOut,
    'Pescados': LineIcons.fish,
    'Especias': FontAwesomeIcons.mortarPestle,
    'Bebidas': LineIcons.beer,
    'Frutas': LineIcons.fruitApple,
    'Lácteos': LineIcons.cheese,
    'Otros': LineIcons.box,
  };

  TextStyle _textStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  // Diálogo para editar producto.
  void _showEditDialog(ProductoInventario producto) {
    final _nameController = TextEditingController(text: producto.name);
    final _precioController = TextEditingController(text: producto.precioCompra.toString());
    final _cantidadDeseadaController = TextEditingController(text: producto.cantidadDeseada.toString());
    final _cantidadAvisoController = TextEditingController(text: producto.cantidadAviso.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar producto'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _precioController,
                  decoration: const InputDecoration(labelText: 'Precio Compra'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _cantidadDeseadaController,
                  decoration: const InputDecoration(labelText: 'Cantidad Deseada'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _cantidadAvisoController,
                  decoration: const InputDecoration(labelText: 'Cantidad Aviso'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () async {
                // Crear un nuevo objeto actualizado, manteniendo la categoría actual.
                final updatedProduct = ProductoInventario(
                  id: producto.id,
                  name: _nameController.text,
                  categoria: producto.categoria,
                  precioCompra: double.tryParse(_precioController.text) ?? producto.precioCompra,
                  cantidadDeseada: int.tryParse(_cantidadDeseadaController.text) ?? producto.cantidadDeseada,
                  cantidadAviso: int.tryParse(_cantidadAvisoController.text) ?? producto.cantidadAviso,
                );
                try {
                  await InventoryApiService.updateProductoInventario(updatedProduct);
                  Navigator.pop(context); // Cierra el diálogo
                  setState(() {
                    // Refresca para mostrar los datos actualizados.
                    _futureProduct = InventoryApiService.getProductoInventarioByName(widget.itemName);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar el producto.
  void _deleteProduct(ProductoInventario producto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: const Text('¿Estás seguro de eliminar este producto?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                try {
                  await InventoryApiService.deleteProductoInventario(producto.id);
                  Navigator.pop(context); // Cierra el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
                  Navigator.pop(context); // Vuelve a la pantalla anterior
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Container(
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
        actions: [
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<ProductoInventario?>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Producto no encontrado'));
          } else {
            final producto = snapshot.data!;
            // Usa el nombre de la categoría del producto para elegir el ícono.
            final iconData = categoryIcons[producto.categoria.name] ?? Icons.category;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 400),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(iconData, size: 100, color: Colors.white),
                            const SizedBox(height: 20),
                            Text('Nombre: ${producto.name}', style: _textStyle()),
                            Text('Categoría: ${producto.categoria.name}', style: _textStyle()),
                            Text('Precio Compra: ${producto.precioCompra}', style: _textStyle()),
                            Text('Cantidad Deseada: ${producto.cantidadDeseada}', style: _textStyle()),
                            Text('Cantidad Aviso: ${producto.cantidadAviso}', style: _textStyle()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _showEditDialog(producto);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text("Editar"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _deleteProduct(producto);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text("Eliminar"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Volver"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
