import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'main.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
  }

  // Insert a book
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert('books', {
      'title': book.title,
      'author': book.author,
      'price': book.price,
      'imageUrl': book.imageUrl,
      'description': book.description,
    });
  }

  // Get all books
  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');

    return List.generate(maps.length, (i) {
      return Book(
        title: maps[i]['title'],
        author: maps[i]['author'],
        price: maps[i]['price'],
        imageUrl: maps[i]['imageUrl'],
        description: maps[i]['description'],
      );
    });
  }

  // Update a book
  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      {
        'title': book.title,
        'author': book.author,
        'price': book.price,
        'imageUrl': book.imageUrl,
        'description': book.description,
      },
      where: 'title = ?',
      whereArgs: [book.title],
    );
  }

  // Delete a book
  Future<int> deleteBook(String title) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Search books
  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Book(
        title: maps[i]['title'],
        author: maps[i]['author'],
        price: maps[i]['price'],
        imageUrl: maps[i]['imageUrl'],
        description: maps[i]['description'],
      );
    });
  }

  // Print database contents
  Future<void> printDatabaseContents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    
    print('\n=== Database Contents ===');
    print('Total books: ${maps.length}');
    
    for (var book in maps) {
      print('\nBook ID: ${book['id']}');
      print('Title: ${book['title']}');
      print('Author: ${book['author']}');
      print('Price: \$${book['price']}');
      print('Image URL: ${book['imageUrl']}');
      print('Description: ${book['description']}');
      print('------------------------');
    }
  }

  // Get database location
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');
    return path;
  }
} 