import 'package:android/models/session_manager.dart';
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
  double _totalActual = 0;

  @override
  void initState() {
    super.initState();
    loadLineas();
  }

  String _formatFecha(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      final List<String> dias = [
        "lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"
      ];
      final List<String> meses = [
        "enero", "febrero", "marzo", "abril", "mayo", "junio",
        "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
      ];

      final String diaSemana = dias[dateTime.weekday - 1];
      final String dia = dateTime.day.toString();
      final String mes = meses[dateTime.month - 1];
      final String anio = dateTime.year.toString();
      final String hora = dateTime.hour.toString().padLeft(2, '0');
      final String minuto = dateTime.minute.toString().padLeft(2, '0');

      return "${_capitalize(diaSemana)}, $dia de $mes de $anio – $hora:$minuto";
    } catch (e) {
      return isoDate;
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future<void> loadLineas() async {
    try {
      List<LineaDePedido> lineas =
          await LineaDePedidoService().getLineasByPedidoId(widget.pedido.id!);
      lineas = lineas.reversed.toList();
      double total = lineas.fold(0, (sum, l) => sum + l.precioUnitario * l.cantidad);

      setState(() {
        _lineas = lineas;
        _totalActual = total;
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
      await LineaDePedidoService().deleteLineaDePedido(linea.id!);
    } else {
      LineaDePedido actualizada = LineaDePedido(
        id: linea.id,
        cantidad: nuevaCantidad,
        precioUnitario: linea.precioUnitario,
        salioDeCocina: linea.salioDeCocina,
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
  double totalLinea = linea.cantidad * linea.precioUnitario;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  productoName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: linea.salioDeCocina ? Colors.green[600] : Colors.orange[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      linea.salioDeCocina ? Icons.check_circle : Icons.access_time,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      linea.salioDeCocina ? 'Entregado' : 'Pendiente',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
              Row(
                children: [
               if (!linea.salioDeCocina)
  IconButton(
    onPressed: () async {
      setState(() => _isLoading = true);
      try {
        await LineaDePedidoService().marcarComoSalidoDeCocina(linea.id!);
        await loadLineas();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    },
    icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
    tooltip: "Marcar como salido",
  ),

                  Text('€${totalLinea.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ],
      ),
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
                    Text(
                      'Fecha: ${_formatFecha(widget.pedido.fecha)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Total: \$${_totalActual.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Productos:',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ..._lineas.map(_buildLineaItem).toList(),
                  ],
                ),
    );
  }
}
