import 'package:cinemapro/pages/seat_matrix_jabir.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model_cheryl.dart';

class DetailPage extends StatefulWidget {
  final MovieModelCheryl movie;

  const DetailPage({super.key, required this.movie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double posX = 20;
  double posY = 0;


void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        posY = screenHeight - 50;
      });
    });
  }

  String _formatPrice_dino(int price) {
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
    final movie = widget.movie;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final durationHours = movie.duration ~/ 60;
    final durationMinutes = movie.duration % 60;
    final durationText = durationHours > 0
        ? '${durationHours}j ${durationMinutes}m'
        : '${durationMinutes}m';

    return Scaffold(
      body: Stack(
      children: [ 
        CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.5,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: movie.movieID,
                child: Image.network(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Image.asset(
                          'assets/icons/gambarRusak.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
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
                        child: CircularProgressIndicator(),
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
                    movie.title,
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
                            Image.asset(
                              'assets/icons/star.png',
                              width: 20,
                              height: 20,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating.toStringAsFixed(1),
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
                            Image.asset(
                              'assets/icons/timer.png',
                              width: 20,
                              height: 20,
                              color: Colors.blue,
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
                          _formatPrice_dino(movie.basePrice),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      Positioned(
        left: posX,
        top: posY,
        child: GestureDetector(
          onPanUpdate: (details) { 
            setState(() {
            posX += details.delta.dx;
            posY += details.delta.dy;
          });
  },
child: ElevatedButton.icon(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Harap Login Terlebih Dahulu!')),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sedang memproses pemesanan')),
          );

          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeatMatrixJabir(
                  movieTitle: movie.title,
                  userId: user.uid,
                  totalPrice: movie.basePrice,
                ),
              )
            );
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal: $e'),
                  backgroundColor: Colors.red,
                )
              );
            }
          }
        },
        icon: Image.asset('assets/icons/chair.png', width: 24, height: 24, color: Colors.white),
        label: const Text('Pilih Kursi', style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
      ),
        ),
      ),
    ),
    ],
    ),
    );
  }
}
