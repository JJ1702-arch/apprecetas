import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/models/resena.dart';
import 'package:recetasapp/services/resena_service.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({
    super.key,
    required this.receta,
  });

  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  final _resenaService = ResenaService();
  final _formKey = GlobalKey<FormState>();
  final _autorController = TextEditingController();
  final _comentarioController = TextEditingController();
  late Future<List<Resena>> _futureResenas;
  int _calificacion = 0;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _futureResenas = _resenaService.obtenerResenas(widget.receta.id);
  }

  @override
  void dispose() {
    _autorController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _guardarResena() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_calificacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una calificación.')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final resenas = await _resenaService.guardarResena(
        widget.receta.id,
        Resena(
          autor: _autorController.text.trim(),
          comentario: _comentarioController.text.trim(),
          calificacion: _calificacion,
          fecha: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _futureResenas = Future.value(resenas);
        _autorController.clear();
        _comentarioController.clear();
        _calificacion = 0;
        _guardando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la reseña: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la receta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              receta.imagenUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/receta_placeholder.png',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ingredientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Preparación',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Reseñas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Resena>>(
            future: _futureResenas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('No se pudieron cargar las reseñas: ${snapshot.error}');
              }
              final resenas = snapshot.data ?? [];
              if (resenas.isEmpty) {
                return const Text('Aún no hay reseñas para esta receta.');
              }
              return Column(
                children: resenas.map(_construirResena).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Escribe una reseña',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _autorController,
                  decoration: const InputDecoration(labelText: 'Tu nombre'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe tu nombre.'
                      : null,
                ),
                TextFormField(
                  controller: _comentarioController,
                  decoration: const InputDecoration(labelText: 'Comentario'),
                  maxLines: 3,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe un comentario.'
                      : null,
                ),
                const SizedBox(height: 8),
                const Text('Calificación'),
                Row(
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: _guardando
                          ? null
                          : () => setState(() => _calificacion = index + 1),
                      icon: Icon(
                        index < _calificacion ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _guardando ? null : _guardarResena,
                  child: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar reseña'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirResena(Resena resena) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                resena.autor,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text('${resena.calificacion}/5'),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resena.comentario),
            const SizedBox(height: 4),
            Text(
              resena.fecha.toLocal().toString().split(' ').first,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}