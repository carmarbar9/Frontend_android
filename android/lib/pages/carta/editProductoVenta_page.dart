import 'dart:convert';

import 'package:android/models/categoria.dart';
import 'package:android/models/session_manager.dart';
import 'package:android/services/service_categoria.dart';
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
  List<Categoria> _categoriasInventario = [];
  Categoria? _categoriaSeleccionada;
  List<ProductoInventario> _productosFiltrados = [];
  ProductoInventario? _ingredienteSeleccionado;
  List<Ingrediente> _ingredientes = [];
  List<ProductoInventario> _inventarioDisponible = [];
  int _cantidad = 1;
  bool _yaCreado = false;
  late ProductoVenta _productoActual;

  @override
  void initState() {
    super.initState();
    _productoActual = widget.producto;
    _nameController = TextEditingController(text: _productoActual.name);
    _precioController = TextEditingController(
      text: _productoActual.precioVenta.toString(),
    );
    if (!widget.isCreating) {
      _loadIngredientes();
    }
    _loadCategoriasInventario(); // ← NUEVO
  }

  void _loadCategoriasInventario() async {
    final negocioId = SessionManager.negocioId!;
    final todas = await CategoryApiService.getCategoriesByNegocioId(negocioId);
    setState(() {
      _categoriasInventario =
          todas.where((cat) => cat.pertenece == "INVENTARIO").toList();
    });
  }

  void _onCategoriaSeleccionada(Categoria? cat) async {
    if (cat == null) return;
    final productos =
        await InventoryApiService.getProductosInventarioByCategoria(cat.name);
    setState(() {
      _categoriaSeleccionada = cat;
      _productosFiltrados =
          productos.where((p) => p.categoria.id == cat.id).toList();
      _ingredienteSeleccionado = null;
    });
  }

  Future<void> _loadProductosPorCategoria(String categoriaNombre) async {
    final productos =
        await InventoryApiService.getProductosInventarioByCategoria(
          categoriaNombre,
        );
    setState(() {
      _productosFiltrados = productos;
      _ingredienteSeleccionado = null;
    });
  }

  Future<void> _loadIngredientes() async {
    final data = await IngredienteService.getIngredientesByProductoVenta(
      _productoActual.id,
    );
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
  if (_productoActual.id == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guarda primero el producto para añadir ingredientes.'),
      ),
    );
    return;
  }

  if (_ingredienteSeleccionado == null) {
    print("❌ No se ha seleccionado un ingrediente");
    return;
  }

  // Imprimir información del ingrediente y el producto seleccionado
  print("🔎 Ingrediente seleccionado: ${_ingredienteSeleccionado?.name} (ID: ${_ingredienteSeleccionado?.id})");
  print("🔎 Cantidad seleccionada: $_cantidad");

  // Verificar si el ingrediente ya existe
  final existente = _ingredientes.firstWhere(
    (ing) => ing.productoInventario.id == _ingredienteSeleccionado!.id,
    orElse: () => Ingrediente(
      id: -1,
      cantidad: 0,
      productoInventario: _ingredienteSeleccionado!,
      productoVenta: _productoActual,
    ),
  );

  if (existente.id != -1) {
    print("✅ Ingrediente ya existe. Actualizando cantidad...");
    print("📝 Actualizando ingrediente ${_ingredienteSeleccionado?.name} con cantidad ${existente.cantidad + _cantidad}");

    await IngredienteService.updateIngrediente(
      id: existente.id,
      cantidad: existente.cantidad + _cantidad,
      productoInventarioId: _ingredienteSeleccionado!.id,
      productoVentaId: _productoActual.id,
    );
  } else {
    print("➕ Añadiendo nuevo ingrediente: ${_ingredienteSeleccionado?.name}");
    print("📝 Nuevo ingrediente, cantidad: $_cantidad");

    final producto = _ingredienteSeleccionado!;
    
    // Obtener el ID correcto de la categoría
    final categoriaId = int.tryParse(_ingredienteSeleccionado!.categoria.id) ?? 0; // Correcto
    final negocioId = int.parse(SessionManager.negocioId!);

    // Log del objeto a enviar
    print("🔎 Enviando ingrediente: {"
        "cantidad: $_cantidad, "
        "productoInventario: {id: ${producto.id}, categoria: {id: $categoriaId, negocio: {id: $negocioId}}}, "
        "productoVenta: {id: ${_productoActual.id}}"
    );

    // Verifica el payload que se va a enviar
    final payload = {
      "cantidad": _cantidad,
      "productoInventario": {
        "id": producto.id,
        "categoria": {
          "id": categoriaId,
          "negocio": {"id": negocioId},
        },
      },
      "productoVenta": {"id": _productoActual.id}
    };

    print("📤 Payload a enviar: ${jsonEncode(payload)}");

    // Llamada para añadir ingrediente
    await IngredienteService.addIngrediente(
      cantidad: _cantidad,
      productoInventarioId: producto.id,
      productoVentaId: _productoActual.id,
      categoriaId: categoriaId,
      negocioId: negocioId,
    );
  }

  _loadIngredientes();
}


  Future<void> _confirmarCambios() async {
    try {
      final updated = ProductoVenta(
        id: _productoActual.id,
        name: _nameController.text,
        precioVenta:
            double.tryParse(_precioController.text) ??
            _productoActual.precioVenta,
        categoria:
            _productoActual.categoria, // <-- Esto ya tiene el categoriaId bien
      );

      if (widget.isCreating && _productoActual.id == 0 && !_yaCreado) {
        final creado = await ProductoVentaService().createProductoVenta(
          updated,
        );

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
          const SnackBar(
            content: Text('Producto creado. Ahora puedes añadir ingredientes.'),
          ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'EDITAR PLATO',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PermanentMarker',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput(
              label: 'Nombre del producto',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            _buildInput(
              label: 'Precio de venta (€)',
              controller: _precioController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            if (!widget.isCreating || _yaCreado) ...[
              const Text(
                'Ingredientes actuales:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B1D42),
                ),
              ),
              const SizedBox(height: 10),
              ..._ingredientes.map(
                (ing) => Card(
                  child: ListTile(
                    title: Text(
                      '${ing.productoInventario.name} (${ing.cantidad})',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFF9B1D42)),
                      onPressed: () => _deleteIngrediente(ing.id),
                    ),
                  ),
                ),
              ),
              const Divider(height: 30),
            ],
            const Text(
              'Añadir ingrediente:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF9B1D42),
              ),
            ),
            const SizedBox(height: 12),

            // Dropdown de categorías con estilo
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: const TextStyle(
                  color: Color(0xFF9B1D42),
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF9B1D42),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF9B1D42),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Categoria>(
                  value: _categoriaSeleccionada,
                  hint: const Text('Selecciona categoría'),
                  isExpanded: true,
                  items:
                      _categoriasInventario.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                  onChanged: _onCategoriaSeleccionada,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dropdown de productos (siempre visible pero desactivado si está vacío)
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Producto',
                labelStyle: const TextStyle(
                  color: Color(0xFF9B1D42),
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF9B1D42),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF9B1D42),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ProductoInventario>(
                  value: _ingredienteSeleccionado,
                  hint: const Text('Selecciona un producto'),
                  isExpanded: true,
                  items:
                      _productosFiltrados.map((prod) {
                        return DropdownMenuItem(
                          value: prod,
                          child: Text(prod.name),
                        );
                      }).toList(),
                  onChanged:
                      _productosFiltrados.isEmpty
                          ? null
                          : (value) {
                            setState(() => _ingredienteSeleccionado = value);
                          },
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Cantidad:'),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '1'),
                    onChanged: (value) {
                      _cantidad = int.tryParse(value) ?? 1;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addIngrediente,
                  style: _vinitoButtonStyle(),
                  child: const Text('Añadir'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _confirmarCambios,
                icon: const Icon(Icons.check, color: Colors.white, size: 28),
                label: Text(
                  widget.isCreating && !_yaCreado ? 'Crear' : 'Confirmar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TitanOne',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B1D42),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9B1D42), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9B1D42), width: 2),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF9B1D42),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  ButtonStyle _vinitoButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF9B1D42),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
