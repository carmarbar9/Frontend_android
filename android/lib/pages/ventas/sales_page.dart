import 'package:flutter/material.dart';
import 'package:android/pages/notificaciones/notifications_page.dart';
import 'package:android/pages/ventas/salesDetails_page.dart';
import 'package:line_icons/line_icons.dart';
import 'package:android/models/lote.dart';
import 'package:android/services/service_inventory.dart';
import 'package:android/services/service_lote.dart';
import 'package:android/services/service_notificacion.dart';



class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  // Lista de ventas de ejemplo, cada venta es un Map con sus datos.
  final List<Map<String, dynamic>> sales = const [
    {
      "table": "MESA 1",
      "price": "50,75€",
      "date": "10/03/2025",
      "waiter": "María Ruiz",
      "isPaid": true,
      "products": [
        {"name": "Coca-Cola", "quantity": "2u"},
        {"name": "Cerveza", "quantity": "1u"},
      ],
    },
    {
      "table": "MESA 2",
      "price": "78,40€",
      "date": "10/03/2025",
      "waiter": "Carlos López",
      "isPaid": true,
      "products": [
        {"name": "Cerveza", "quantity": "2u"},
        {"name": "Ensalada", "quantity": "1u"},
      ],
    },
    {
      "table": "MESA 3",
      "price": "100,25€",
      "date": "09/03/2025",
      "waiter": "Ana Martínez",
      "isPaid": false,
      "products": [
        {"name": "Presa Ibérica", "quantity": "1u"},
        {"name": "Solomillo de Cerdo", "quantity": "1u"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Separamos las ventas según su estado
    final paidSales = sales.where((sale) => sale["isPaid"] == true).toList();
    final pendingSales = sales.where((sale) => sale["isPaid"] == false).toList();

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () async {
              try {
                final productos = await InventoryApiService.getProductosInventario();

                final Map<int, List<Lote>> lotesPorProducto = {};
                for (var producto in productos) {
                  final lotes = await LoteProductoService.getLotesByProductoId(producto.id);
                  lotesPorProducto[producto.id] = lotes;
                }

                final notificaciones = NotificacionService()
                    .generarNotificacionesInventario(productos, lotesPorProducto);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificacionPage(),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cargar notificaciones: $e')),
                );
              }
            },
          ),

          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'VENTAS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Buscar',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Filtrar',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 10),
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
                  // Sección de ventas pagadas
                  const Text(
                    "Pagadas",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ...paidSales.map((sale) => _buildSaleCard(
                        context,
                        sale["table"],
                        sale["price"],
                        sale["date"],
                        sale["isPaid"],
                        sale["waiter"],
                        sale["products"],
                      )),
                  const SizedBox(height: 20),
                  // Sección de ventas pendientes
                  const Text(
                    "Pendientes de pago",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ...pendingSales.map((sale) => _buildSaleCard(
                        context,
                        sale["table"],
                        sale["price"],
                        sale["date"],
                        sale["isPaid"],
                        sale["waiter"],
                        sale["products"],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSaleCard(BuildContext context, String table, String price,
    String date, bool isPaid, String waiter, List<Map<String, String>> products) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SaleDetailPage(
            table: table,
            date: date,
            waiter: waiter,
            total: price,
            isPaid: isPaid,
            products: products,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color.fromARGB(255, 167, 45, 77)
            : const Color.fromARGB(255, 146, 82, 93),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Columna con datos de la venta
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                table,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isPaid ? "Pagada" : "Pendiente",
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 80), // Espacio entre la columna y el icono
          // Icono según el estado de la venta
          Icon(
            isPaid ? LineIcons.checkCircleAlt : LineIcons.clock,
            color: isPaid ? Colors.greenAccent : Colors.orangeAccent,
            size: 70,
          ),
        ],
      ),
    ),
  );
}
}
