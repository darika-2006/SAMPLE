import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';
import 'config/theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookStore',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}

class Book {
  final String title;
  final String author;
  final double price;
  final String imageUrl;
  final String description;

  Book({
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'],
      author: map['author'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      description: map['description'],
    );
  }
}

class BookStorePage extends StatefulWidget {
  const BookStorePage({super.key});

  @override
  State<BookStorePage> createState() => _BookStorePageState();
}

class _BookStorePageState extends State<BookStorePage> with SingleTickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Book> _books = [];
  String _searchQuery = '';
  Book? _selectedBook;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _databaseHelper.getAllBooks();
      if (books.isEmpty) {
        // If no books in database, add sample books
        await _addSampleBooks();
        final loadedBooks = await _databaseHelper.getAllBooks();
        setState(() {
          _books = loadedBooks;
        });
      } else {
        setState(() {
          _books = books;
        });
      }
    } catch (e) {
      print('Error loading books: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleBooks() async {
    final sampleBooks = [
      Book(
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        price: 19.99,
        imageUrl: 'assets/images/book1.jpg',
        description: 'A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.',
      ),
      Book(
        title: 'To Kill a Mockingbird',
        author: 'Harper Lee',
        price: 15.99,
        imageUrl: 'assets/images/book2.jpg',
        description: 'The story of racial injustice and the loss of innocence in the American South.',
      ),
      Book(
        title: '1984',
        author: 'George Orwell',
        price: 14.99,
        imageUrl: 'assets/images/book3.jpg',
        description: 'A dystopian social science fiction novel and cautionary tale.',
      ),
      Book(
        title: 'Pride and Prejudice',
        author: 'Jane Austen',
        price: 12.99,
        imageUrl: 'assets/images/book4.jpg',
        description: 'A romantic novel of manners.',
      ),
    ];

    for (var book in sampleBooks) {
      await _databaseHelper.insertBook(book);
    }
  }

  Future<void> _searchBooks(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      if (query.isEmpty) {
        final books = await _databaseHelper.getAllBooks();
        setState(() {
          _books = books;
        });
      } else {
        final books = await _databaseHelper.searchBooks(query);
        setState(() {
          _books = books;
        });
      }
    } catch (e) {
      print('Error searching books: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report),
                onPressed: () async {
                  // Print database path
                  final dbPath = await _databaseHelper.getDatabasePath();
                  print('\nDatabase location: $dbPath');
                  
                  // Print database contents
                  await _databaseHelper.printDatabaseContents();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('BookStore'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search books or authors...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchBooks(''),
                            )
                          : null,
                    ),
                    onChanged: _searchBooks,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _selectedBook == null
                  ? SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final book = _books[index];
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: BookCard(
                                book: book,
                                onTap: () {
                                  setState(() {
                                    _selectedBook = book;
                                  });
                                },
                              ),
                            );
                          },
                          childCount: _books.length,
                        ),
                      ),
                    )
                  : SliverFillRemaining(
                      child: BookDetailView(
                        book: _selectedBook!,
                        onBack: () {
                          setState(() {
                            _selectedBook = null;
                          });
                        },
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add new book functionality
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final Function() onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    book.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.book, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        '\$${book.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailView extends StatelessWidget {
  final Book book;
  final Function() onBack;

  const BookDetailView({
    super.key,
    required this.book,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: 'book-${book.title}',
                child: Image.asset(
                  book.imageUrl,
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 400,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.book, size: 100, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${book.author}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${book.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
