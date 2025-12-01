import 'package:cloud_firestore/cloud_firestore.dart';

class BookingServiceJabir {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}