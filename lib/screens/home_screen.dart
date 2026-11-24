import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/screens/detalle_receta_screen.dart';
import 'package:recetasapp/services/recipes_service.dart';
import 'package:recetasapp/widgets/receta_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Receta>> _futureRecetas;

  final TextEditingController _buscadorController = TextEditingController();
  List<Receta> _recetasFiltradas = [];
  List<Receta> _todasLasRecetas = [];

  @override
  void initState() {
    super.initState();
    _futureRecetas = _recipeService.obtenerRecetas();
  }

  void _filtrarRecetas(String texto) {
    setState(() {
      _recetasFiltradas = _todasLasRecetas.where((receta) {
        return receta.nombre.toLowerCase().contains(texto.trim().toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas del Mayab by JJ'),
        backgroundColor: const Color.fromARGB(255, 179, 29, 2),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _buscadorController,
              onChanged: _filtrarRecetas,
              decoration: InputDecoration(
                hintText: 'Buscar receta...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Receta>>(
              future: _futureRecetas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (_todasLasRecetas.isEmpty) {
                  _todasLasRecetas = snapshot.data!;
                  _recetasFiltradas = snapshot.data!;
                }

                if (_recetasFiltradas.isEmpty) {
                  return const Center(child: Text('No se encontraron recetas'));
                }

                final recetas = _recetasFiltradas;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: recetas.length,
                  itemBuilder: (context, index) {
                    return RecetaCard(
                      receta: recetas[index],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalleRecetaScreen(receta: recetas[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
