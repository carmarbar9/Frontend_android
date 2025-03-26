import 'package:android/models/producto_inventario.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/services/service_inventory.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class ItemDetailsPage extends StatefulWidget {
  final String itemName;
  final String category; // Para íconos o navegación

  const ItemDetailsPage({super.key, required this.itemName, required this.category});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  // Guardará el producto que cargamos
  late Future<ProductoInventario?> _futureProduct;

  // Para la búsqueda
  String? _searchQuery;

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

  @override
  void initState() {
    super.initState();
    _loadItem(); // Cargamos el producto según itemName
  }

  // =====================================
  // 1. Lógica de carga y búsqueda
  // =====================================
  void _loadItem() {
    // Si _searchQuery está vacío, usamos widget.itemName (lo original)
    // Si _searchQuery tiene algo, buscamos ese nuevo nombre
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      _futureProduct = InventoryApiService.getProductoInventarioByName(widget.itemName);
    } else {
      // Aquí podrías usar un método que haga búsqueda parcial
      // o primero obtener todos y filtrar en memoria
      // Por simplicidad, llamamos al mismo getProductoInventarioByName
      // y asumimos que el backend admite nombres parciales (o devuelva el primero que coincida)
      _futureProduct = InventoryApiService.getProductoInventarioByName(_searchQuery!);
    }
  }

  void _showSearchDialog() async {
    String? query;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Buscar Producto",
            style: TextStyle(color: Color(0xFF9B1D42), fontWeight: FontWeight.bold),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: "Ingresa parte del nombre",
              hintStyle: TextStyle(color: const Color(0xFF9B1D42).withOpacity(0.6)),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF9B1D42)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF9B1D42), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(color: Color(0xFF9B1D42), fontWeight: FontWeight.bold),
            onChanged: (value) {
              query = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Color(0xFF9B1D42))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Buscar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if ((query ?? '').isNotEmpty) {
      setState(() {
        _searchQuery = query;
      });
      _loadItem(); // Recargamos con la nueva búsqueda
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _loadItem();
    });
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

   TextStyle _textStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/logo.png', fit: BoxFit.contain),
          onPressed: () => Navigator.pop(context),
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
      body: Column(
        children: [
          // Título y Botón de Buscar
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'DETALLE PRODUCTO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFamily: 'PermanentMarker',
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B1D42),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _showSearchDialog,
                  icon: const Icon(Icons.search),
                  label: const Text("Buscar"),
                ),
              ],
            ),
          ),

          // Si hay una búsqueda, mostramos el Chip
          if (_searchQuery != null && _searchQuery!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Chip(
                backgroundColor: const Color(0xFF9B1D42).withOpacity(0.2),
                label: Text(
                  "Búsqueda: $_searchQuery",
                  style: const TextStyle(color: Color(0xFF9B1D42), fontWeight: FontWeight.bold),
                ),
                deleteIcon: const Icon(Icons.close, color: Color(0xFF9B1D42)),
                onDeleted: _clearSearch,
              ),
            ),

          // Expandimos para mostrar el FutureBuilder
          Expanded(
            child: FutureBuilder<ProductoInventario?>(
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
                  final iconData = categoryIcons[producto.categoria.name] ?? Icons.category;
                  return _buildProductDetails(producto, iconData);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(ProductoInventario producto, IconData iconData) {
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
                    onPressed: () => _showEditDialog(producto),
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
                    onPressed: () => _deleteProduct(producto),
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
}