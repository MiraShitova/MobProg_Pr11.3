import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/library_book.dart';
import '../providers/library_provider.dart';

class MyLibraryScreen extends StatefulWidget {
  @override
  _MyLibraryScreenState createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Library'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Want to Read'),
              Tab(text: 'Read'),
            ],
          ),
        ),
        body: Consumer<LibraryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            final wantToReadBooks = provider.books.where((b) => b.status == 'want_to_read').toList();
            final readBooks = provider.books.where((b) => b.status == 'read').toList();

            return TabBarView(
              children: [
                _buildBookList(wantToReadBooks, provider),
                _buildBookList(readBooks, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookList(List<LibraryBook> books, LibraryProvider provider) {
    if (books.isEmpty) {
      return Center(child: Text('No books in this section.'));
    }
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading: book.coverUrl != null
              ? CachedNetworkImage(
                  imageUrl: book.coverUrl!,
                  width: 50,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.book),
                )
              : Icon(Icons.book, size: 50),
          title: Text(book.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.authors.join(', ')),
              if (book.rating > 0) Text('Rating: ${book.rating} ⭐'),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => provider.removeBook(book.id),
          ),
          onLongPress: () => _showEditDialog(book, provider),
        );
      },
    );
  }
  
  void _showEditDialog(LibraryBook book, LibraryProvider provider) {
    double currentRating = book.rating == 0 ? 5.0 : book.rating;
    final notesController = TextEditingController(text: book.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Book Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rating:'),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<double>(
                  value: currentRating,
                  onChanged: (val) => setState(() => currentRating = val!),
                  items: [1.0, 2.0, 3.0, 4.0, 5.0]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.toString())))
                      .toList(),
                );
              },
            ),
            TextField(
              controller: notesController,
              decoration: InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              final updatedBook = book.copyWith(
                rating: currentRating,
                notes: notesController.text,
              );
              provider.updateBook(updatedBook);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
