import 'package:flutter/material.dart';
import 'package:android/models/mesa.dart';
import 'package:android/pages/pedidos/order_detail_page.dart';

class MesaDetailPage extends StatefulWidget {
  final Mesa mesa;
  const MesaDetailPage({Key? key, required this.mesa}) : super(key: key);

  @override
  _MesaDetailPageState createState() => _MesaDetailPageState();
}

class _MesaDetailPageState extends State<MesaDetailPage> {
  // Orden: clave es el nombre del producto y valor es la cantidad
  Map<String, int> _order = {};

  // Dummy categorías y productos con más datos en "Platos Principales" y "Bebidas"
  final List<Map<String, dynamic>> _categories = [
    {
      'category': 'Entradas',
      'products': [
        'Ensalada',
        'Sopa',
        'Pan con ajo',
        'Tomate aliñao',
        'Papas aliñas'
      ],
    },
    {
      'category': 'Platos Principales',
      'products': [
        'Hamburguesa',
        'Pizza',
        'Pasta',
        'Arroz con pollo',
        'Carne asada',
        'Lasaña',
        'Pollo a la brasa'
      ],
    },
    {
      'category': 'Postres',
      'products': ['Helado', 'Pastel', 'Fruta'],
    },
    {
      'category': 'Bebidas',
      'products': [
        'Cerveza',
        'Refresco',
        'Agua',
        'Vinos',
        'Jugo natural',
        'Café',
        'Té',
        'Smoothie'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Pedidos, Acciones, Cuenta
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mesa.name ?? "Mesa"),
          backgroundColor: const Color(0xFF9B1D42),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            unselectedLabelColor: Colors.white70,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Pedidos"),
              Tab(text: "Acciones"),
              Tab(text: "Cuenta"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPedidosTab(),
            _buildAccionesTab(),
            _buildCuentaTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidosTab() {
    return Container(
      color: const Color(0xFF9B1D42),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Botón "Comanda" para ver la orden actual y actualizarla al regresar
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9B1D42),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              // Navega a OrderDetailPage y espera el resultado (orden actualizada)
              final updatedOrder = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailPage(order: _order),
                ),
              );
              if (updatedOrder != null && updatedOrder is Map<String, int>) {
                setState(() {
                  _order = updatedOrder;
                });
              }
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text("Comanda"),
          ),
          const SizedBox(height: 20),
          // Listado de categorías y productos
          ..._categories.map((cat) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat['category'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: (cat['products'] as List).length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      String product = (cat['products'] as List)[index];
                      int quantity = _order[product] ?? 0;
                      return _buildProductCard(product, quantity);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductCard(String product, int quantity) {
    return InkWell(
      onTap: () {
        setState(() {
          int current = _order[product] ?? 0;
          _order[product] = current + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$product añadido. ¿Deseas deshacer?"),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: "Deshacer",
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  int current = _order[product] ?? 0;
                  if (current > 0) {
                    _order[product] = current - 1;
                  }
                });
              },
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              product,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B1D42),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Cantidad: $quantity",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildAccionesTab() {
  return Container(
    color: const Color(0xFF9B1D42),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.people, color: Colors.white),
          label: const Text(
            "Asignar Comensales",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            // Aquí implementa la lógica para asignar comensales.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Asignar número de comensales")),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.table_bar, color: Colors.white),
          label: const Text(
            "Unir Mesas",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            // Aquí implementa la lógica para unir mesas.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unir mesas")),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.swap_horiz, color: Colors.white),
          label: const Text(
            "Transferir Datos",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            // Aquí implementa la lógica para transferir datos de una mesa a otra.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Transferir datos de una mesa a otra")),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.cleaning_services, color: Colors.white),
          label: const Text(
            "Limpiar Datos",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            // Aquí implementa la lógica para limpiar los datos de la mesa.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Limpiar datos de la mesa")),
            );
          },
        ),
      ],
    ),
  );
}


  Widget _buildCuentaTab() {
    return Container(
      color: const Color(0xFF9B1D42),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen de Cuenta",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Divider(color: Colors.white70),
          const ListTile(
            title: Text("Total pedidos:", style: TextStyle(color: Colors.white)),
            trailing: Text("\$45.00", style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            title: Text("Descuento:", style: TextStyle(color: Colors.white)),
            trailing: Text("\$5.00", style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            title: Text("Total a pagar:", style: TextStyle(color: Colors.white)),
            trailing: Text("\$40.00", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 211, 67, 110),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                // Lógica para finalizar la cuenta y cerrar mesa
              },
              child: const Text(
                "Finalizar Cuenta",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
