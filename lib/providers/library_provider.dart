import 'package:flutter/material.dart';
import '../models/library_book.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class LibraryProvider with ChangeNotifier {
  List<LibraryBook> _books = [];
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  List<LibraryBook> get books => _books;
  bool get isLoading => _isLoading;

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    final userId = await _authService.getUserId();
    if (userId != null) {
      _books = await _dbService.getAllLocalBooks(userId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBook(LibraryBook book) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    await _dbService.saveBookToLocal(book, userId);
    _books.add(book);
    notifyListeners();
  }

  Future<void> updateBook(LibraryBook book) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    await _dbService.saveBookToLocal(book, userId);
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
      notifyListeners();
    }
  }

  Future<void> removeBook(String id) async {
    await _dbService.deleteLocalBook(id);
    _books.removeWhere((book) => book.id == id);
    notifyListeners();
  }
}
