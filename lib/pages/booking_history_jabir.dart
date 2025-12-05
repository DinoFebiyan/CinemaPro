import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinemapro/services/booking_service.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String? userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Riwayat Booking'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text('User tidak terautentikasi'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Booking'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('user_id', isEqualTo: userId)
            .orderBy('booking_date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Belum ada riwayat booking'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];
              var bookingData = booking.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID: ${bookingData['booking_id'] ?? 'N/A'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatDate(bookingData['booking_date']),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Film: ${bookingData['movie_title'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Kursi: ${bookingData['seats'] != null ? (bookingData['seats'] as List).join(', ') : 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total Harga: Rp ${(bookingData['total_price'] ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{3})$|^(\d{3})(?=\d)', multiLine: true), (Match m) => '${m[0]},-')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic dateField) {
    if (dateField == null) return 'N/A';
    
    Timestamp timestamp;
    if (dateField is Timestamp) {
      timestamp = dateField;
    } else if (dateField is DateTime) {
      timestamp = Timestamp.fromDate(dateField);
    } else {
      return 'N/A';
    }
    
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }
}