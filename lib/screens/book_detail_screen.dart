import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/library_book.dart';
import '../providers/library_provider.dart';
import '../services/book_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  BookDetailScreen({required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _bookService = BookService();
  String? _description;
  bool _isLoadingDescription = true;

  @override
  void initState() {
    super.initState();
    _loadDescription();
  }

  void _loadDescription() async {
    final desc = await _bookService.getBookDescription(widget.book.id);
    if (mounted) {
      setState(() {
        _description = desc;
        _isLoadingDescription = false;
      });
    }
  }

  void _addToLibrary(String status) async {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    
    final exists = provider.books.any((b) => b.bookId == widget.book.id);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This book is already in your library')),
      );
      return;
    }

    final libraryBook = LibraryBook(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: widget.book.id,
      title: widget.book.title,
      authors: widget.book.authors,
      coverUrl: widget.book.coverUrl,
      status: status,
    );

    await provider.addBook(libraryBook);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to library!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Details')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: widget.book.coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: widget.book.coverUrl!,
                            height: 250,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.book, size: 100),
                          )
                        : Icon(Icons.book, size: 100),
                  ),
                  SizedBox(height: 20),
                  Text(widget.book.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('By: ${widget.book.authors.join(', ')}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (_isLoadingDescription)
                    Center(child: CircularProgressIndicator())
                  else
                    Text(_description ?? 'No description available.'),
                  SizedBox(height: 100), // Space for buttons
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addToLibrary('want_to_read'),
                    child: Text('Want to Read'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addToLibrary('read'),
                    child: Text('Mark as Read'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
