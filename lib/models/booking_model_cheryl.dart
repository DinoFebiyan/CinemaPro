import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModelCheryl {
  final String bookingId;
  final String userId;
  final String movieTitle;
  final List<String> seats;
  final int totalPrice;
  final DateTime bookingDate;

  BookingModelCheryl({
    required this.bookingId,
    required this.userId,
    required this.movieTitle,
    required this.seats,
    required this.totalPrice,
    required this.bookingDate,
  });

  Map<String, dynamic> toMap_Cheryl() {
    return {
      'booking_id' : bookingId,
      'user_id' : userId,
      'movie_title' : movieTitle,
      'seats' : seats,
      'total_price' : totalPrice,
      'booking_date' : Timestamp.fromDate(bookingDate),
    };
  }

  factory BookingModelCheryl.fromMap_Cheryl(Map<String, dynamic> map, String id) {
    return BookingModelCheryl(
      bookingId: id, 
      userId: map ['userId'] ?? '', 
      movieTitle: map ['movieTitle'] ?? '' , 
      seats: List<String>.from(map['seats'] ?? []), 
      totalPrice: map ['totalPrice']?.toInt() ?? 0, 
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      );
  }
}