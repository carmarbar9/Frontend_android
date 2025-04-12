import 'package:flutter/material.dart';
import 'package:android/models/pedido.dart';
import 'package:android/models/linea_de_pedido.dart';
import 'package:android/services/service_lineaPedido.dart';

class OrderInfoPage extends StatefulWidget {
  final Pedido pedido;

  const OrderInfoPage({Key? key, required this.pedido}) : super(key: key);

  @override
  _OrderInfoPageState createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  List<LineaDePedido> _lineas = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    loadLineas();
  }

Future<void> loadLineas() async {
  try {
    List<LineaDePedido> lineas = await LineaDePedidoService().getLineasByPedidoId(widget.pedido.id!);
    lineas = lineas.reversed.toList(); // Invertimos el orden
    setState(() {
      _lineas = lineas;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}


  Future<void> _actualizarCantidad(LineaDePedido linea, int cambio) async {
    final nuevaCantidad = linea.cantidad + cambio;

    if (nuevaCantidad <= 0) {
      // Eliminar línea si la cantidad va a ser 0 o menor
      await LineaDePedidoService().deleteLineaDePedido(linea.id!);
    } else {
      // Actualizar línea con nueva cantidad y precio recalculado
      final nuevoPrecio = (linea.precioLinea / linea.cantidad) * nuevaCantidad;

      LineaDePedido actualizada = LineaDePedido(
        id: linea.id,
        cantidad: nuevaCantidad,
        precioLinea: nuevoPrecio,
        pedidoId: linea.pedidoId,
        productoId: linea.productoId,
        productoName: linea.productoName,
      );

      await LineaDePedidoService().updateLineaDePedido(actualizada);
    }

    await loadLineas();
  }

  Widget _buildLineaItem(LineaDePedido linea) {
    String productoName = linea.productoName ?? "Producto ${linea.productoId}";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(productoName),
        subtitle: Row(
          children: [
            IconButton(
              onPressed: () => _actualizarCantidad(linea, -1),
              icon: const Icon(Icons.remove, color: Colors.red),
            ),
            Text('${linea.cantidad}', style: const TextStyle(fontSize: 16)),
            IconButton(
              onPressed: () => _actualizarCantidad(linea, 1),
              icon: const Icon(Icons.add, color: Colors.green),
            ),
          ],
        ),
        trailing: Text('\$${linea.precioLinea.toStringAsFixed(2)}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles del Pedido ${widget.pedido.id}"),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Fecha: ${widget.pedido.fecha}', style: const TextStyle(fontSize: 18)),
                    Text('Total: \$${widget.pedido.precioTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    const Text('Productos:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ..._lineas.map(_buildLineaItem).toList(),
                  ],
                ),
    );
  }
}
