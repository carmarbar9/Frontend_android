import 'package:flutter/material.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, int> order;
  final Function(Map<String, int>)? onOrderChanged; // Callback opcional

  const OrderDetailPage({
    Key? key,
    required this.order,
    this.onOrderChanged,
  }) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Map<String, int> _order;

  @override
  void initState() {
    super.initState();
    // Clonamos la orden para editarla localmente.
    _order = Map.from(widget.order);
  }

  // Función auxiliar para actualizar la orden y notificar el cambio.
  void _updateOrder(String key, int newValue) {
    setState(() {
      _order[key] = newValue;
    });
    if (widget.onOrderChanged != null) {
      widget.onOrderChanged!(_order);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Comanda"),
        backgroundColor: const Color(0xFF9B1D42),
      ),
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Por cada entrada de la orden, se crea una Card bonita.
          ..._order.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nombre del producto o ítem.
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Controles para disminuir o aumentar la cantidad.
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (entry.value > 0) {
                              _updateOrder(entry.key, entry.value - 1);
                            }
                          },
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _updateOrder(entry.key, entry.value + 1);
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          // Botón para finalizar la orden y regresar la orden actualizada.
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1D42),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, _order);
              },
              child: const Text(
                "Finalizar Orden",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
