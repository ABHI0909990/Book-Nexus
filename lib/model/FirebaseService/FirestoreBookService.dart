import 'package:book_nexus/model/Book/ReadingHistoryEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FirestoreBookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get user document reference
  DocumentReference? get _userDocRef =>
      _currentUserId != null ? _usersCollection.doc(_currentUserId) : null;

  // Get user's saved books collection reference
  CollectionReference? get _userSavedBooksCollection =>
      _currentUserId != null ? _userDocRef?.collection('saved_books') : null;

  // Get user's favorites collection reference
  CollectionReference? get _userFavoritesCollection =>
      _currentUserId != null ? _userDocRef?.collection('favorites') : null;

  // Get user's reading history collection reference
  CollectionReference? get _userReadingHistoryCollection =>
      _currentUserId != null
          ? _userDocRef?.collection('reading_history')
          : null;

  // Get user's reading history entries collection reference
  CollectionReference? get _userReadingHistoryEntriesCollection =>
      _currentUserId != null
          ? _userDocRef?.collection('reading_history_entries')
          : null;

  // Save a book to user's saved books
  Future<bool> saveBook(Map<String, dynamic> bookData) async {
    if (_currentUserId == null || _userSavedBooksCollection == null) {
      Get.snackbar('Error', 'You must be logged in to save books');
      return false;
    }

    try {
      String bookId =
          bookData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Add to saved books with timestamp
      await _userSavedBooksCollection!.doc(bookId).set({
        ...bookData,
        'savedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Book saved successfully');
      return true;
    } catch (e) {
      print('Error saving book: $e');
      Get.snackbar('Error', 'Failed to save book');
      return false;
    }
  }

  // Remove a book from saved books
  Future<bool> removeBook(String bookId) async {
    if (_currentUserId == null || _userSavedBooksCollection == null) {
      Get.snackbar('Error', 'You must be logged in to manage saved books');
      return false;
    }

    try {
      await _userSavedBooksCollection!.doc(bookId).delete();
      Get.snackbar('Success', 'Book removed from saved books');
      return true;
    } catch (e) {
      print('Error removing book: $e');
      Get.snackbar('Error', 'Failed to remove book');
      return false;
    }
  }

  // Get user's saved books
  Future<List<Map<String, dynamic>>?> getSavedBooks() async {
    if (_currentUserId == null || _userSavedBooksCollection == null) {
      Get.snackbar('Error', 'You must be logged in to view saved books');
      return null;
    }

    try {
      final QuerySnapshot snapshot = await _userSavedBooksCollection!
          .orderBy('savedAt', descending: true)
          .get();

      return _processBookSnapshots(snapshot);
    } catch (e) {
      print('Error getting saved books: $e');
      return null;
    }
  }

  // Check if a book is saved
  Future<bool> isBookSaved(String bookId) async {
    if (_currentUserId == null || _userSavedBooksCollection == null) {
      return false;
    }

    try {
      final DocumentSnapshot doc =
          await _userSavedBooksCollection!.doc(bookId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if book is saved: $e');
      return false;
    }
  }

  // Add book to favorites
  Future<bool> addToFavorites(String bookId) async {
    if (_currentUserId == null ||
        _userFavoritesCollection == null ||
        _userSavedBooksCollection == null) {
      Get.snackbar('Error', 'You must be logged in to add favorites');
      return false;
    }

    try {
      // Get the book data first from saved books
      final DocumentSnapshot doc =
          await _userSavedBooksCollection!.doc(bookId).get();

      if (!doc.exists) {
        Get.snackbar('Error', 'Book not found in your saved books');
        return false;
      }

      final bookData = doc.data() as Map<String, dynamic>;

      // Add to favorites with timestamp
      await _userFavoritesCollection!.doc(bookId).set({
        ...bookData,
        'addedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Book added to favorites');
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      Get.snackbar('Error', 'Failed to add book to favorites');
      return false;
    }
  }

  // Remove book from favorites
  Future<bool> removeFromFavorites(String bookId) async {
    if (_currentUserId == null || _userFavoritesCollection == null) {
      Get.snackbar('Error', 'You must be logged in to manage favorites');
      return false;
    }

    try {
      await _userFavoritesCollection!.doc(bookId).delete();
      Get.snackbar('Success', 'Book removed from favorites');
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      Get.snackbar('Error', 'Failed to remove book from favorites');
      return false;
    }
  }

  // Get user's favorite books
  Future<List<Map<String, dynamic>>?> getFavoriteBooks() async {
    if (_currentUserId == null || _userFavoritesCollection == null) {
      Get.snackbar('Error', 'You must be logged in to view favorites');
      return null;
    }

    try {
      final QuerySnapshot snapshot = await _userFavoritesCollection!
          .orderBy('addedAt', descending: true)
          .get();

      return _processBookSnapshots(snapshot);
    } catch (e) {
      print('Error getting favorite books: $e');
      return null;
    }
  }

  // Add book to reading history (updates the most recent reading record)
  Future<bool> addToReadingHistory(String bookId, double progress) async {
    if (_currentUserId == null ||
        _userReadingHistoryCollection == null ||
        _userSavedBooksCollection == null) {
      Get.snackbar('Error', 'You must be logged in to track reading history');
      return false;
    }

    try {
      // Get the book data first from saved books
      final DocumentSnapshot doc =
          await _userSavedBooksCollection!.doc(bookId).get();

      if (!doc.exists) {
        Get.snackbar('Error', 'Book not found in your saved books');
        return false;
      }

      final bookData = doc.data() as Map<String, dynamic>;

      // Add to reading history with timestamp and progress
      await _userReadingHistoryCollection!.doc(bookId).set({
        ...bookData,
        'lastReadAt': FieldValue.serverTimestamp(),
        'progress': progress,
      });

      // Also add a detailed reading history entry
      await addReadingHistoryEntry(bookId, bookData['title'] ?? 'Unknown Book',
          bookData['imageLinks']?['thumbnail'], progress);

      return true;
    } catch (e) {
      print('Error adding to reading history: $e');
      return false;
    }
  }

  // Add a detailed reading history entry
  Future<bool> addReadingHistoryEntry(
      String bookId, String bookTitle, String? bookCoverUrl, double progress,
      [int duration = 0]) async {
    if (_currentUserId == null ||
        _userReadingHistoryEntriesCollection == null) {
      Get.snackbar('Error', 'You must be logged in to track reading history');
      return false;
    }

    try {
      // Create a new reading history entry with current timestamp
      final ReadingHistoryEntry entry = ReadingHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: bookId,
        bookTitle: bookTitle,
        bookCoverUrl: bookCoverUrl,
        readDate: Timestamp.now(),
        progress: progress,
        duration: duration, // Include reading duration
      );

      // Add to reading history entries collection
      await _userReadingHistoryEntriesCollection!.add(entry.toFirestore());
      return true;
    } catch (e) {
      print('Error adding reading history entry: $e');
      return false;
    }
  }

  // Get user's reading history (most recent reading for each book)
  Future<List<Map<String, dynamic>>?> getReadingHistory() async {
    if (_currentUserId == null || _userReadingHistoryCollection == null) {
      Get.snackbar('Error', 'You must be logged in to view reading history');
      return null;
    }

    try {
      final QuerySnapshot snapshot = await _userReadingHistoryCollection!
          .orderBy('lastReadAt', descending: true)
          .get();

      return _processBookSnapshots(snapshot);
    } catch (e) {
      print('Error getting reading history: $e');
      return null;
    }
  }

  // Get all reading history entries for calendar view
  Future<List<ReadingHistoryEntry>?> getReadingHistoryEntries() async {
    if (_currentUserId == null ||
        _userReadingHistoryEntriesCollection == null) {
      Get.snackbar('Error', 'You must be logged in to view reading history');
      return null;
    }

    try {
      final QuerySnapshot snapshot = await _userReadingHistoryEntriesCollection!
          .orderBy('readDate', descending: true)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((doc) => ReadingHistoryEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting reading history entries: $e');
      return null;
    }
  }

  // Get reading history entries for a specific date range
  Future<List<ReadingHistoryEntry>?> getReadingHistoryEntriesForDateRange(
      DateTime startDate, DateTime endDate) async {
    if (_currentUserId == null ||
        _userReadingHistoryEntriesCollection == null) {
      Get.snackbar('Error', 'You must be logged in to view reading history');
      return null;
    }

    try {
      final Timestamp startTimestamp = Timestamp.fromDate(startDate);
      final Timestamp endTimestamp = Timestamp.fromDate(endDate);

      final QuerySnapshot snapshot = await _userReadingHistoryEntriesCollection!
          .where('readDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('readDate', isLessThanOrEqualTo: endTimestamp)
          .orderBy('readDate', descending: true)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((doc) => ReadingHistoryEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting reading history entries for date range: $e');
      return null;
    }
  }

  // Process book snapshots into a list of maps
  List<Map<String, dynamic>>? _processBookSnapshots(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) return [];

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}
