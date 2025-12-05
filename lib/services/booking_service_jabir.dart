import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingServiceJabir {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new booking in Firestore
  Future<String> createBooking({
    required String movieTitle,
    required List<String> seats,
    required int totalPrice,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Auto-generate booking ID
      final bookingId = "BK-${DateTime.now().millisecondsSinceEpoch}";
      
      // Create booking document
      await _firestore.collection('bookings').add({
        'booking_id': bookingId,
        'user_id': user.uid,
        'movie_title': movieTitle,
        'seats': seats,
        'total_price': totalPrice,
        'booking_date': FieldValue.serverTimestamp(),
      });

      return bookingId;
    } catch (e) {
      print('Error creating booking: $e');
      throw e;
    }
  }

  // Get booked seats for a specific movie
  Future<List<String>> getBookedSeatsForMovie(String movieTitle) async {
    try {
      QuerySnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .where('movie_title', isEqualTo: movieTitle)
          .get();

      List<String> bookedSeats = [];

      for (QueryDocumentSnapshot doc in bookingSnapshot.docs) {
        List<dynamic> seats = doc.get('seats') as List<dynamic>;
        for (dynamic seat in seats) {
          if (seat is String) {
            bookedSeats.add(seat);
          }
        }
      }

      return bookedSeats;
    } catch (e) {
      print('Error fetching booked seats: $e');
      return [];
    }
  }

  // Get all bookings for a specific movie
  Future<QuerySnapshot> getBookingsForMovie(String movieTitle) async {
    try {
      return await _firestore
          .collection('bookings')
          .where('movie_title', isEqualTo: movieTitle)
          .get();
    } catch (e) {
      print('Error fetching bookings: $e');
      rethrow;
    }
  }

  // Get bookings for a specific user
  Future<QuerySnapshot> getUserBookings(String userId) async {
    try {
      return await _firestore
          .collection('bookings')
          .where('user_id', isEqualTo: userId)
          .get();
    } catch (e) {
      print('Error fetching user bookings: $e');
      rethrow;
    }
  }

  // Get a specific booking by booking ID
  Future<DocumentSnapshot> getBookingById(String bookingId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('booking_id', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        throw Exception('Booking not found');
      }
    } catch (e) {
      print('Error fetching booking: $e');
      rethrow;
    }
  }
}