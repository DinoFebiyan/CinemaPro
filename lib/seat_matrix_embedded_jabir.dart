import 'package:flutter/material.dart';

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

// Embeddable seat matrix widget for use in other pages
class SeatMatrixWidgetJabir extends StatefulWidget {
  final String movieTitle;
  final String userId;
  final int basePrice;
  final List<String> bookedSeats;
  final int maxSeats; // Added to limit seat selection based on ticket count
  final ValueChanged<List<String>>? onSeatsSelected; // Callback when seats change

  const SeatMatrixWidgetJabir({
    Key? key,
    required this.movieTitle,
    required this.userId,
    required this.basePrice,
    this.bookedSeats = const [],
    this.maxSeats = 10, // Default to allow up to 10 seats
    this.onSeatsSelected,
  }) : super(key: key);

  @override
  _SeatMatrixWidgetJabirState createState() => _SeatMatrixWidgetJabirState();
}

class _SeatMatrixWidgetJabirState extends State<SeatMatrixWidgetJabir> {
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
        // Deselect the seat
        seatStatuses[seatNumber] = SeatStatus.available;
        selectedSeats.remove(seatNumber);
      } else {
        // Check if user has reached the maximum number of seats allowed by ticket count
        if (selectedSeats.length >= widget.maxSeats) {
          // Show a snackbar if they try to select more than allowed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maksimal ${widget.maxSeats} kursi dapat dipilih sesuai jumlah tiket'),
              backgroundColor: Colors.orange,
            ),
          );
          return; // Don't select the seat
        }
        // Select the seat
        seatStatuses[seatNumber] = SeatStatus.selected;
        selectedSeats.add(seatNumber);
      }
    });

    // Notify parent widget of seat selection changes
    if (widget.onSeatsSelected != null) {
      widget.onSeatsSelected!(selectedSeats);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            'Layar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 10),

        // Seat grid with scroll
        Container(
          height: 300, // Fixed height for seat grid
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (int row = 0; row < 10; row++)
                  _buildSeatRow(row),
              ],
            ),
          ),
        ),

        SizedBox(height: 10),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(Colors.grey[300]!, 'Tersedia'),
            _buildLegendItem(Colors.blue, 'Dipilih'),
            _buildLegendItem(Colors.red, 'Terjual'),
          ],
        ),

        SizedBox(height: 10),

        // Selected seats info
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Kursi Terpilih: ${selectedSeats.isNotEmpty ? selectedSeats.join(', ') : 'Belum ada'}',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
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