import 'package:android/models/producto_inventario.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/services/service_inventory.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class ItemDetailsPage extends StatefulWidget {
  final String itemName;
  final String category;

  const ItemDetailsPage({super.key, required this.itemName, required this.category});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late Future<ProductoInventario?> _futureProduct;

  @override
  void initState() {
    super.initState();
    // Se consulta el backend para obtener los detalles del producto por nombre.
    _futureProduct = InventoryApiService.getProductoInventarioByName(widget.itemName);
  }

  // Map de íconos según categoría.
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
      fontSize: 25,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0, // Remover la sombra del AppBar
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
          // Icono de notificaciones
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
          // Icono de perfil
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
            // El icono se selecciona según la categoría almacenada en el producto
            final iconData = categoryIcons[producto.categoria] ?? Icons.category;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
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
                          Text('Categoría: ${producto.categoria}', style: _textStyle()),
                          Text('Precio Compra: ${producto.precioCompra} €', style: _textStyle()),
                          Text('Cantidad Deseada: ${producto.cantidadDeseada}', style: _textStyle()),
                          Text('Cantidad Aviso: ${producto.cantidadAviso}', style: _textStyle()),
                          // Si tienes fechas de expiración, agrégalas aquí
                        ],
                      ),
                    ),
                    const SizedBox(height: 30, width: 10),
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
                            // Acción para editar
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Editar"),
                        ),
                        const SizedBox(height: 30, width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            // Acción para eliminar
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
            );
          }
        },
      ),
    );
  }
}
