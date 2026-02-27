class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String? firstPublishYear;
  final String? coverUrl;
  final String? description;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.firstPublishYear,
    this.coverUrl,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['key'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      authors: (json['author_name'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      firstPublishYear: json['first_publish_year']?.toString(),
      coverUrl: json['cover_i'] != null
          ? 'https://covers.openlibrary.org/b/id/${json['cover_i']}-M.jpg'
          : null,
    );
  }
}
