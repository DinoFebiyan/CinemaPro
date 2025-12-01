import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';

class BookingServiceIsal {
  Future bookingMovie_Isal({
    required String movieTitle,
    required int basePrice,
    required List<String> selectedSeats,
  }) async {
    int totalBase_isal = basePrice * selectedSeats.length;
    int tax_isal = 0;
    double discount_isal = 0;

    // the long title tax, jika jumlah karakter pada judul film > 10 maka harga tiket ditambah Rp 2.500,- per kursi
    if (movieTitle.length > 10) {
      tax_isal = selectedSeats.length * 2500;
    }

    for (var seat_isal in selectedSeats) {
      String numberString_isal = seat_isal.substring(1); // "A2" -> "2"
      int seatNumber_isal = int.tryParse(numberString_isal) ?? 1; // default ganjil kalau error
      // jika seatNumber habis dibagi 2 (genap)
      if(seatNumber_isal % 2 == 0) {
        discount_isal += basePrice * 0.1;
      }
    }

    double finalPrice = (totalBase_isal + tax_isal) - discount_isal;
    
    final String bookingId = "BK-${DateTime.now().millisecondsSinceEpoch}";
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('bookings').add({
      'booking_id': bookingId,
      'user_id': user?.uid,
      'movie_title': movieTitle,
      'seats': selectedSeats,
      'total_price': finalPrice,
      'booking_date': FieldValue.serverTimestamp(),
    });
    
    return true;
  }
}
