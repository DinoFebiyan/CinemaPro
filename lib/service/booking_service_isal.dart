import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';

// class BookingServiceIsal untuk menampung fungsi yang berkaitan dengan booking film
class BookingServiceIsal {
  // fungsi bookingMovie_Isal bertipe Future, artinya fungsi ini berjalan di latar belakang (async) jadi fungsi lain bisa berjalan tanpa menunggu fungsi ini selesai
  Future bookingMovie_Isal({
    required String movieTitle, // parameter untuk menampung judul film yang mau dibooking
    required int basePrice, // parameter untuk menampung harga asli dari film yang mau dibooking
    required List<String> selectedSeats, // parameter untuk menampung List kursi yang mau dibooking
  }) async {
    int totalBase_isal = basePrice * selectedSeats.length; // harga asli dari jumlah kursi yang mau dibooking dikalikan dengan harga asli satuan film
    int tax_isal = 0; // menampung nilai pajak yang didapat dari aturan soal
    double discount_isal = 0; // menampung nilai diskon yang didapat dari aturan soal

    // the long title tax, jika jumlah karakter pada judul film > 10 maka harga tiket ditambah Rp 2.500,- per kursi
    if (movieTitle.length > 10) {
      tax_isal = selectedSeats.length * 2500;
    }

    // melakukan perulangan untuk melakukan pengecekan tiap nilai didalam List tempat duduk yang mau dibooking
    for (var seat_isal in selectedSeats) {
      String numberString_isal = seat_isal.substring(1); // nilai pada List dalam suatu index berupa string seperti ini "A2" kemudian dengan substring(1) memanggil index ke-1 dari nilai string sebelumnya jadi yang direturn adalah "2"
      int seatNumber_isal = int.tryParse(numberString_isal) ?? 1; // mencoba mengubah numberString_isal menjadi integer, jika gagal maka secara default nilainya adalah 1 yakni ganjil tanpa diskon
      // jika seatNumber habis dibagi 2 (genap) maka diberi diskon sebanyak 10% per kursinya.
      if(seatNumber_isal % 2 == 0) {
        // discoutn_isal bertambah 10% dari harga asli film
        discount_isal += basePrice * 0.1;
      }
    }

    // menghitung harga akhir dengan menambahkan harga asli dengan nilai pajak kemudian dikurangi dengan diskon
    double finalPrice = (totalBase_isal + tax_isal) - discount_isal;

    // membuat id booking dengan format BK-waktu saat ini
    final String bookingId = "BK-${DateTime.now().millisecondsSinceEpoch}";
    // memanggil data user saat ini yang sedang login
    final user = FirebaseAuth.instance.currentUser;

    // melakukan proses insert data ke collection booking
    await FirebaseFirestore.instance.collection('bookings').add({
      'booking_id': bookingId,
      'user_id': user?.uid,
      'movie_title': movieTitle,
      'seats': selectedSeats,
      'total_price': finalPrice,
      'booking_date': FieldValue.serverTimestamp(),
    });

    // mengembalikan nilai true, artinya insert data berhasil
    return true;
  }
}
