import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:android/models/pedido.dart';
import 'package:android/pages/ventas/salesDetails_page.dart';
import 'package:android/services/service_pedido.dart';
import 'package:android/models/session_manager.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final PedidoService pedidoService = PedidoService();
  List<Pedido> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    try {
      final negocioId = int.parse(SessionManager.negocioId!);
      print("EEEEERRRRROOOOOORRRR ${SessionManager.negocioId}");
      final results = await pedidoService.loadPedidosByNegocioId(negocioId);
      setState(() {
        pedidos = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar pedidos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Pedido> get paidSales => pedidos.where((p) => p.precioTotal < 100).toList(); // Lógica temporal
  List<Pedido> get pendingSales => pedidos.where((p) => p.precioTotal >= 100).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/logo.png',
            height: 60,
            width: 60,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Aquí puedes redirigir a tu página de notificaciones si lo deseas
            },
          ),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'VENTAS',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGreyButton('Buscar', () {}),
                      const SizedBox(width: 10),
                      _buildGreyButton('Filtrar', () {}),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 30),
                    label: const Text(
                      "Añadir",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          "Pagadas",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ...paidSales.map((p) => _buildSaleCard(context, p, true)),
                        const SizedBox(height: 20),
                        const Text(
                          "Pendientes de pago",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ...pendingSales.map((p) => _buildSaleCard(context, p, false)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGreyButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black)),
    );
  }

  Widget _buildSaleCard(BuildContext context, Pedido pedido, bool isPaid) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaleDetailPage(
              table: "MESA ${pedido.mesaId}",
              date: pedido.fecha.split("T").first,
              waiter: "Empleado ${pedido.empleadoId}",
              total: "${pedido.precioTotal.toStringAsFixed(2)}€",
              isPaid: isPaid,
              products: [], // Si luego añades líneas de pedido, aquí se cargan
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPaid ? const Color.fromARGB(255, 167, 45, 77) : const Color.fromARGB(255, 146, 82, 93),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("MESA ${pedido.mesaId}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("${pedido.precioTotal.toStringAsFixed(2)}€",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(pedido.fecha.split("T").first, style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 5),
                Text(isPaid ? "Pagada" : "Pendiente",
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white)),
              ],
            ),
            const SizedBox(width: 80),
            Icon(isPaid ? LineIcons.checkCircleAlt : LineIcons.clock,
                color: isPaid ? Colors.greenAccent : Colors.orangeAccent, size: 70),
          ],
        ),
      ),
    );
  }
}
