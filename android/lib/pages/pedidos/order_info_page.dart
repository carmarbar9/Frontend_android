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

  // Para mostrar cada línea de pedido. Se asume que la respuesta incluye el nombre del producto
  // dentro del objeto "producto". Si no es el caso, se mostrará "Producto {id}".
Widget _buildLineaItem(LineaDePedido linea) {
  // Si el campo productoName está definido, se muestra; en caso contrario, se muestra un fallback.
  String productoName = linea.productoName ?? "Producto ${linea.productoId}";
  return ListTile(
    title: Text(productoName),
    subtitle: Text('Cantidad: ${linea.cantidad}'),
    trailing: Text('\$${linea.precioLinea.toStringAsFixed(2)}'),
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
                    ..._lineas.map((linea) => _buildLineaItem(linea)).toList(),
                  ],
                ),
    );
  }
}
