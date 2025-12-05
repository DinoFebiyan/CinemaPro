import 'package:cinemapro/pages/seat_matrix_jabir.dart';
import 'package:cinemapro/service/booking_service_isal.dart';
import 'package:cinemapro/services/booking_service_jabir.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model_cheryl.dart';
import '../ticket_counter_jabir.dart';
import '../seat_matrix_embedded_jabir.dart';
import '../services/booking_service_jabir.dart';

class DetailPage extends StatefulWidget {
  final MovieModelCheryl movie;

  const DetailPage({super.key, required this.movie});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int ticketCount = 1;
  List<String> selectedSeats = [];
  List<String> bookedSeats = [];
  bool _isLoading = true;
  final BookingServiceJabir _oldBookingService = BookingServiceJabir(); // Used for fetching booked seats
  final BookingServiceJabir _newBookingService = BookingServiceJabir(); // Used for creating bookings

  @override
  void initState() {
    super.initState();
    _fetchBookedSeats();
  }

  Future<void> _fetchBookedSeats() async {
    try {
      List<String> seats = await _oldBookingService.getBookedSeatsForMovie(widget.movie.title);
      setState(() {
        bookedSeats = seats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching booked seats: $e');
    }
  }

  void _onTicketCountChanged(int count) {
    setState(() {
      ticketCount = count;
    });
  }

  void _onSeatsSelected(List<String> seats) {
    setState(() {
      selectedSeats = seats;
    });
  }

  // Calculate final price with additional fees and discounts
  int _calculateFinalPrice() {
    int totalBase = widget.movie.basePrice * selectedSeats.length;
    int tax = 0;
    double discount = 0;

    // Long title tax: if movie title length > 10 characters, add Rp 2,500 per seat
    if (widget.movie.title.length > 10) {
      tax = selectedSeats.length * 2500;
    }

    // Discount for even-numbered seats: 10% discount per even-numbered seat
    for (var seat in selectedSeats) {
      String numberString = seat.substring(1); // "A2" -> "2"
      int seatNumber = int.tryParse(numberString) ?? 1;
      if (seatNumber % 2 == 0) {
        discount += widget.movie.basePrice * 0.1;
      }
    }

    int finalPrice = (totalBase + tax - discount).round();
    return finalPrice;
  }

  // Handle booking confirmation
  Future<void> _handleBooking() async {
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan pilih kursi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Memproses booking..."),
              ],
            ),
          );
        },
      );

      // Calculate the final price with any additional fees/discounts
      int finalPrice = _calculateFinalPrice();

      // Create the booking in Firestore
      String bookingId = await _newBookingService.createBooking(
        movieTitle: widget.movie.title,
        seats: selectedSeats,
        totalPrice: finalPrice,
      );

      // Close the loading dialog
      Navigator.of(context).pop();

      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Booking Berhasil!"),
            content: Text(
              "Booking ID: $bookingId\n"
              "Film: ${widget.movie.title}\n"
              "Kursi: ${selectedSeats.join(", ")}\n"
              "Total Pembayaran: Rp ${finalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{3})$|^(\d{3})(?=\d)', multiLine: true), (Match m) => '${m[0]},-')}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate back to home or clear the selection
                  setState(() {
                    selectedSeats = [];
                  });
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close the loading dialog if it's still open
      Navigator.of(context).pop();

      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Booking Gagal"),
            content: Text("Terjadi kesalahan saat memproses booking: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  String _formatPrice(int price) {
    final priceStr = price.toString();
    final buffer = StringBuffer('Rp ');
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final durationHours = widget.movie.duration ~/ 60;
    final durationMinutes = widget.movie.duration % 60;
    final durationText = durationHours > 0
        ? '${durationHours}j ${durationMinutes}m'
        : '${durationMinutes}m';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.5,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.movie.movieID,
                child: Image.network(
                  widget.movie.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    widget.movie.title,
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              durationText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Tiket',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(widget.movie.basePrice),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ticket Count Selection and Seat Matrix Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Jumlah Tiket & Kursi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // Ticket Counter Widget
                        TicketCounterJabir(
                          basePrice: widget.movie.basePrice,
                          onTicketCountChanged: _onTicketCountChanged,
                        ),

                        const SizedBox(height: 20),

                        // Loading indicator while fetching booked seats
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          // Seat Matrix Widget
                          SeatMatrixWidgetJabir(
                            movieTitle: widget.movie.title,
                            userId: FirebaseAuth.instance.currentUser?.uid ?? 'user001', // Get the current user ID
                            basePrice: widget.movie.basePrice,
                            bookedSeats: bookedSeats, // Booked seats from database
                            maxSeats: ticketCount, // Limit seats based on ticket count
                            onSeatsSelected: _onSeatsSelected,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleBooking,
        icon: const Icon(Icons.confirmation_number),
        label: const Text('Pesan Sekarang'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
