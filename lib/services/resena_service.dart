import 'dart:convert';

import 'package:recetasapp/models/resena.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResenaService {
  static const _keyPrefix = 'resenas_receta_';

  Future<List<Resena>> obtenerResenas(int recetaId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedReviews = preferences.getString('$_keyPrefix$recetaId');
    if (storedReviews == null) {
      return [];
    }

    final decoded = jsonDecode(storedReviews);
    if (decoded is! List) {
      throw const FormatException('El almacenamiento de reseñas no es válido.');
    }

    final reviews = decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('Una reseña almacenada no es válida.');
      }
      return Resena.fromJson(Map<String, dynamic>.from(item));
    }).toList();
    reviews.sort((a, b) => b.fecha.compareTo(a.fecha));
    return reviews;
  }

  Future<List<Resena>> guardarResena(int recetaId, Resena resena) async {
    final preferences = await SharedPreferences.getInstance();
    final reviews = await obtenerResenas(recetaId);
    reviews.add(resena);
    reviews.sort((a, b) => b.fecha.compareTo(a.fecha));

    final saved = await preferences.setString(
      '$_keyPrefix$recetaId',
      jsonEncode(reviews.map((review) => review.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('No se pudo guardar la reseña.');
    }
    return reviews;
  }
}
