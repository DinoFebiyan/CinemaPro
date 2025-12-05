import 'package:cinemapro/services/booking_service_jabir.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SeatItem widget representing a single seat
class SeatItemJabir extends StatelessWidget {
  final String seatNumber;
  final SeatStatus status;
  final VoidCallback? onTap;
  final bool isSelected;

  const SeatItemJabir({
    Key? key,
    required this.seatNumber,
    required this.status,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    bool isInteractive = true;

    switch (status) {
      case SeatStatus.available:
        seatColor = isSelected ? Colors.blue : Colors.grey[300]!;
        break;
      case SeatStatus.selected:
        seatColor = Colors.blue;
        break;
      case SeatStatus.booked:
        seatColor = Colors.red;
        isInteractive = false;
        break;
      default:
        seatColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: isInteractive ? onTap : null,
      child: Container(
        width: 35,
        height: 35,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            seatNumber,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: status == SeatStatus.booked ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

enum SeatStatus { available, selected, booked }

class SeatMatrixJabir extends StatefulWidget {
  final String movieTitle;
  final String userId;
  final int basePrice;
  final List<String> bookedSeats;

  const SeatMatrixJabir({
    Key? key,
    required this.movieTitle,
    required this.userId,
    required this.basePrice,
    this.bookedSeats = const [],
  }) : super(key: key);

  @override
  _SeatMatrixJabirState createState() => _SeatMatrixJabirState();
}

class _SeatMatrixJabirState extends State<SeatMatrixJabir> {
  Map<String, SeatStatus> seatStatuses = {};
  List<String> selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  void _initializeSeats() {
    // Initialize all seats as available
    for (int row = 0; row < 10; row++) {
      String rowLabel = String.fromCharCode(65 + row); // A, B, C, etc.
      for (int col = 1; col <= 5; col++) {
        String seatNumber = '${rowLabel}${col}';
        seatStatuses[seatNumber] = widget.bookedSeats.contains(seatNumber)
            ? SeatStatus.booked
            : SeatStatus.available;
      }
    }
  }

  void _toggleSeat(String seatNumber) {
    if (seatStatuses[seatNumber] == SeatStatus.booked) {
      return; // Can't select booked seats
    }

    setState(() {
      if (seatStatuses[seatNumber] == SeatStatus.selected) {
        seatStatuses[seatNumber] = SeatStatus.available;
        selectedSeats.remove(seatNumber);
      } else {
        seatStatuses[seatNumber] = SeatStatus.selected;
        selectedSeats.add(seatNumber);
      }
    });
  }

  // Calculate final price with additional fees and discounts
  int _calculateFinalPrice() {
    int totalBase = widget.basePrice * selectedSeats.length;
    int tax = 0;
    double discount = 0;

    // Long title tax: if movie title length > 10 characters, add Rp 2,500 per seat
    if (widget.movieTitle.length > 10) {
      tax = selectedSeats.length * 2500;
    }

    // Discount for even-numbered seats: 10% discount per even-numbered seat
    for (var seat in selectedSeats) {
      String numberString = seat.substring(1); // "A2" -> "2"
      int seatNumber = int.tryParse(numberString) ?? 1;
      if (seatNumber % 2 == 0) {
        discount += widget.basePrice * 0.1;
      }
    }

    int finalPrice = (totalBase + tax - discount).round();
    return finalPrice;
  }

  // Confirm booking and send data to Firebase
  void _confirmBooking() async {
    if (selectedSeats.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silakan pilih kursi terlebih dahulu'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Calculate the final price
      int finalPrice = _calculateFinalPrice();

      // Create booking using the new service
      final bookingService = BookingServiceJabir();
      String bookingId = await bookingService.createBooking(
        movieTitle: widget.movieTitle,
        seats: selectedSeats,
        totalPrice: finalPrice,
      );

      if (context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking berhasil! ID: $bookingId'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelBooking() {
    // Reset all selected seats
    setState(() {
      for (String seat in selectedSeats) {
        if (seatStatuses[seat] == SeatStatus.selected) {
          seatStatuses[seat] = SeatStatus.available;
        }
      }
      selectedSeats.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selection cleared'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Seats'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Screen indicator
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'SCREEN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Seat grid with scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int row = 0; row < 10; row++) _buildSeatRow(row),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.grey[300]!, 'Available'),
                _buildLegendItem(Colors.blue, 'Selected'),
                _buildLegendItem(Colors.red, 'Booked'),
              ],
            ),

            SizedBox(height: 20),

            // Selected seats info
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Selected Seats: ${selectedSeats.isNotEmpty ? selectedSeats.join(', ') : 'None'}',
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 20),

            // Price information
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Harga Tiket: Rp ${widget.basePrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{3})$|^(\d{3})(?=\d)', multiLine: true), (Match m) => '${m[0]},-')}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Jumlah Kursi: ${selectedSeats.length}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Total (setelah pajak/diskon): Rp ${_calculateFinalPrice().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{3})$|^(\d{3})(?=\d)', multiLine: true), (Match m) => '${m[0]},-')}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _cancelBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedSeats.isEmpty ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('Confirm (${selectedSeats.length} seats)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatRow(int rowIndex) {
    String rowLabel = String.fromCharCode(65 + rowIndex);
    List<Widget> seats = [];

    for (int col = 1; col <= 5; col++) {
      String seatNumber = '${rowLabel}${col}';
      bool isSelected = selectedSeats.contains(seatNumber);

      seats.add(
        SeatItemJabir(
          seatNumber: seatNumber,
          status: seatStatuses[seatNumber]!,
          isSelected: isSelected,
          onTap: () => _toggleSeat(seatNumber),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 35,
            child: Center(
              child: Text(
                rowLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 10),
          ...seats,
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
