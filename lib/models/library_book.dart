class LibraryBook {
  final String id;
  final String bookId;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final String status;
  final double rating;
  final String notes;

  LibraryBook({
    required this.id,
    required this.bookId,
    required this.title,
    required this.authors,
    this.coverUrl,
    required this.status,
    this.rating = 0,
    this.notes = '',
  });

  LibraryBook copyWith({
    String? status,
    double? rating,
    String? notes,
  }) {
    return LibraryBook(
      id: this.id,
      bookId: this.bookId,
      title: this.title,
      authors: this.authors,
      coverUrl: this.coverUrl,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'authors': authors.join(','),
      'coverUrl': coverUrl,
      'status': status,
      'rating': rating,
      'notes': notes,
    };
  }

  factory LibraryBook.fromMap(Map<String, dynamic> map) {
    return LibraryBook(
      id: map['id'],
      bookId: map['bookId'],
      title: map['title'],
      authors: map['authors'].toString().isEmpty ? [] : map['authors'].toString().split(','),
      coverUrl: map['coverUrl'],
      status: map['status'],
      rating: (map['rating'] as num).toDouble(),
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory LibraryBook.fromJson(Map<String, dynamic> json) => LibraryBook.fromMap(json);
}
