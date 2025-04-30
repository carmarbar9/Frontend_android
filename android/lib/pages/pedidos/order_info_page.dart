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
      color: linea.salioDeCocina ? Colors.green[50] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    productoName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: linea.salioDeCocina ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        linea.salioDeCocina ? Icons.check : Icons.hourglass_bottom,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        linea.salioDeCocina ? 'Entregado' : 'Pendiente',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                linea.salioDeCocina
                    ? Text(
                      'Cantidad: ${linea.cantidad}',
                        style: const TextStyle(fontSize: 16),
                      )
                    : Row(
                        children: [
                          IconButton(
                            onPressed: () => _actualizarCantidad(linea, -1),
                            icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                          ),
                          Text(
                            '${linea.cantidad}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () => _actualizarCantidad(linea, 1),
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                          ),
                        ],
                      ),
                Row(
                  children: [
                    if (!linea.salioDeCocina)
                      IconButton(
                        tooltip: 'Marcar como entregado',
                        icon: const Icon(Icons.local_shipping, color: Colors.blueAccent),
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
                      ),
                    Text(
                      '€${totalLinea.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF9B1D42),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatFecha(widget.pedido.fecha),
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Total: €${_totalActual.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Productos:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ..._lineas.map(_buildLineaItem).toList(),
                  ],
                ),
    );
  }
}
