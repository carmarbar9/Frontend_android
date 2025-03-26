import 'package:flutter/material.dart';
import 'package:android/models/producto_venta.dart';
import 'package:android/models/producto_inventario.dart';
import 'package:android/models/ingrediente.dart';
import 'package:android/services/service_carta.dart';
import 'package:android/services/service_ingrediente.dart';
import 'package:android/services/service_inventory.dart';

class EditProductoVentaPage extends StatefulWidget {
  final ProductoVenta producto;
  final bool isCreating;

  const EditProductoVentaPage({
    super.key,
    required this.producto,
    this.isCreating = false,
  });

  @override
  State<EditProductoVentaPage> createState() => _EditProductoVentaPageState();
}

class _EditProductoVentaPageState extends State<EditProductoVentaPage> {
  late TextEditingController _nameController;
  late TextEditingController _precioController;

  List<Ingrediente> _ingredientes = [];
  List<ProductoInventario> _inventarioDisponible = [];
  ProductoInventario? _ingredienteSeleccionado;
  int _cantidad = 1;
  bool _yaCreado = false;
  late ProductoVenta _productoActual;

  @override
  void initState() {
    super.initState();
    _productoActual = widget.producto;
    _nameController = TextEditingController(text: _productoActual.name);
    _precioController = TextEditingController(text: _productoActual.precioVenta.toString());
    if (!widget.isCreating) {
      _loadIngredientes();
    }
    _loadInventario();
  }

  Future<void> _loadIngredientes() async {
    final data = await IngredienteService.getIngredientesByProductoVenta(_productoActual.id);
    setState(() => _ingredientes = data);
  }

  Future<void> _loadInventario() async {
    final data = await InventoryApiService.getAllProductosInventario();
    setState(() => _inventarioDisponible = data);
  }

  Future<void> _deleteIngrediente(int id) async {
    await IngredienteService.deleteIngrediente(id);
    _loadIngredientes();
  }

  Future<void> _addIngrediente() async {
    if (_ingredienteSeleccionado == null || _productoActual.id == 0) return;

    final existente = _ingredientes.firstWhere(
      (ing) => ing.productoInventario.id == _ingredienteSeleccionado!.id,
      orElse: () => Ingrediente(id: -1, cantidad: 0, productoInventario: _ingredienteSeleccionado!, productoVenta: _productoActual),
    );

    if (existente.id != -1) {
      await IngredienteService.updateIngrediente(
        id: existente.id,
        cantidad: existente.cantidad + _cantidad,
        productoInventarioId: _ingredienteSeleccionado!.id,
        productoVentaId: _productoActual.id,
      );
    } else {
      await IngredienteService.addIngrediente(
        cantidad: _cantidad,
        productoInventarioId: _ingredienteSeleccionado!.id,
        productoVentaId: _productoActual.id,
      );
    }

    _loadIngredientes();
  }

  Future<void> _confirmarCambios() async {
    try {
      final updated = ProductoVenta(
        id: _productoActual.id,
        name: _nameController.text,
        precioVenta: double.tryParse(_precioController.text) ?? _productoActual.precioVenta,
        categoria: _productoActual.categoria,
      );

      if (widget.isCreating && _productoActual.id == 0 && !_yaCreado) {
        final creado = await ProductoVentaService().createProductoVenta(updated);

        setState(() {
          _productoActual = ProductoVenta(
            id: creado.id,
            name: creado.name,
            precioVenta: creado.precioVenta,
            categoria: creado.categoria,
          );
          _yaCreado = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado. Ahora puedes añadir ingredientes.')),
        );

        _loadIngredientes();
      } else {
        await ProductoVentaService().updateProductoVenta(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreating ? 'Crear nuevo plato' : 'Editar: ${_productoActual.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio de venta'),
              ),
              const SizedBox(height: 20),
              if (!widget.isCreating || _yaCreado) ...[
                const Text('Ingredientes actuales:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                for (var ing in _ingredientes)
                  ListTile(
                    tileColor: Colors.grey[200],
                    title: Text('${ing.productoInventario.name} (${ing.cantidad})'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteIngrediente(ing.id),
                    ),
                  ),
                const Divider(height: 30),
              ],
              const Text('Añadir ingrediente:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<ProductoInventario>(
                value: _ingredienteSeleccionado,
                hint: const Text('Selecciona un producto'),
                isExpanded: true,
                items: _inventarioDisponible.map((prod) {
                  return DropdownMenuItem(
                    value: prod,
                    child: Text(prod.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _ingredienteSeleccionado = value);
                },
              ),
              Row(
                children: [
                  const Text('Cantidad:'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '1'),
                      onChanged: (value) {
                        _cantidad = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addIngrediente,
                    child: const Text('Añadir'),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _confirmarCambios,
                  icon: const Icon(Icons.check),
                  label: Text(
                    widget.isCreating && !_yaCreado ? 'Crear' : 'Confirmar',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}