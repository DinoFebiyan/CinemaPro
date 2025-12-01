import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../models/booking_model_cheryl.dart';

class ProfileCheryl extends StatefulWidget {
  const ProfileCheryl({super.key});

  @override
  State<ProfileCheryl> createState() => _ProfileCherylState();
}

class _ProfileCherylState extends State<ProfileCheryl> {
  final String currentUserId_Cheryl = FirebaseAuth.instance.currentUser!.uid;

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Riwayat Tiket Saya'),
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
      .collection('bookings') 
      .where('user_id', isEqualTo: currentUserId_Cheryl)
      .orderBy('booking_date', descending: true)
      .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Belum ada Riwayat Pemesanan Tiket'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final booking = BookingModelCheryl.fromMap_Cheryl(data, doc.id);

            return _buildTicketCard_Cheryl(booking);
          },
        );
      }
      ),
  );
 }

 Widget _buildTicketCard_Cheryl (BookingModelCheryl booking) {
  final String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(booking.bookingDate);

  final String formattedPrice = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0
  ).format(booking.totalPrice);

  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.movieTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Kursi: ${booking.seats.join(', ')}"),
                    const SizedBox(height: 4),
                    Text("Tanggal: $formattedDate"),
                    const SizedBox(height: 8),
                    Text(
                      "Total: $formattedPrice",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                ),
                Column(
                  children: [
                    QrImageView(
                      data: booking.bookingId,
                      version: QrVersions.auto,
                      size: 80.0,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Scan Me",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    )
                  ],
                )
            ],
          )
        ],
      ),
    ),
  );
 }
} 