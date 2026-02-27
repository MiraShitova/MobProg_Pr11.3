import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../utils/constants.dart';

class BookService {
  Future<List<Book>> searchBooks(String query) async {
    if (query.isEmpty) return [];
    
    final url = Uri.parse('${Constants.openLibraryBaseUrl}/search.json?q=${Uri.encodeComponent(query)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List docs = data['docs'] ?? [];
        return docs.map((doc) => Book.fromJson(doc)).toList();
      }
    } catch (e) {
      print('Search error: $e');
    }
    return [];
  }

  Future<String?> getBookDescription(String bookKey) async {
    final url = Uri.parse('${Constants.openLibraryBaseUrl}$bookKey.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final description = data['description'];
        if (description is String) return description;
        if (description is Map) return description['value'];
      }
    } catch (e) {
      print('Description error: $e');
    }
    return null;
  }
}
