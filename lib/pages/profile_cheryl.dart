import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model_cheryl.dart';
import '../models/user_model_cheryl.dart'; 

class ProfilePageCheryl extends StatelessWidget {
  const ProfilePageCheryl({super.key});

  @override
  Widget build(BuildContext context) {
    
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

   
    if (currentUserId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Silakan Login terlebih dahulu")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator(); 
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Data user tidak ditemukan"),
                );
              }

              
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              
              final user = UserModelCheryl.fromMapCheryl(userData); 

              return Container(
                color: Colors.blue,
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: Row(
                  children: [
                    // Avatar Icon
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    // Info User
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username, // Nama User
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.email, // Email User
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            "Saldo: Rp ${user.balance}", // Saldo User
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: const Text(
              "Riwayat Pemesanan Tiket",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),

          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('user_id', isEqualTo: currentUserId) 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_creation_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Belum ada tiket yang dibeli.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final booking = BookingModelCheryl.fromMap_Cheryl(
                        doc.data() as Map<String, dynamic>, doc.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.movieTitle,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Kursi: ${booking.seats.join(', ')}"),
                                  Text(
                                    "Total: Rp ${booking.totalPrice}",
                                    style: const TextStyle(
                                        color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Tgl: ${booking.bookingDate.toString().substring(0, 10)}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            // QR Code
                            Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: QrImageView(
                                    data: booking.bookingId,
                                    version: QrVersions.auto,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text("Scan Me", style: TextStyle(fontSize: 9)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}