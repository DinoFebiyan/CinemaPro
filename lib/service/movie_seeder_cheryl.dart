import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model_cheryl.dart';

class MovieSeederCheryl {
  final List<MovieModelCheryl> _moviesData = [
    MovieModelCheryl(
      movieID: 'mv01', 
      title: 'Up', 
      posterUrl: 'https://upload.wikimedia.org/wikipedia/en/0/05/Up_%282009_film%29.jpg', 
      basePrice: 30000, 
      rating: 4.8, 
      duration: 96,
      ),
      MovieModelCheryl(
        movieID: 'mv02', 
        title: 'Coco', 
        posterUrl: 'https://upload.wikimedia.org/wikipedia/en/9/98/Coco_%282017_film%29_poster.jpg', 
        basePrice: 35000, 
        rating: 4.9, 
        duration: 105,
        ),
      MovieModelCheryl(
      movieID: 'mv03',
      title: 'Frozen',
      posterUrl: 'https://m.media-amazon.com/images/M/MV5BMTQ1MjQwMTE5OF5BMl5BanBnXkFtZTgwNjk3MTcyMDE@._V1_.jpg',
      basePrice: 40000,
      rating: 4.8,
      duration: 137,
    ),
    MovieModelCheryl(
      movieID: 'mv04',
      title: 'Venom',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/id/thumb/0/05/Venom_poster.jpg/250px-Venom_poster.jpg',
      basePrice: 50000,
      rating: 4.2,
      duration: 112,
    ),
    MovieModelCheryl(
      movieID: 'mv05',
      title: 'Dilan 1990',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/id/1/19/Dilan_1990_%28poster%29.jpg',
      basePrice: 35000,
      rating: 4.6,
      duration: 110,
    ),
    MovieModelCheryl(
      movieID: 'mv06',
      title: 'Pengabdi Setan2: Communion',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/id/2/26/Pengabdi_Setan_2.jpeg',
      basePrice: 50000,
      rating: 4.7,
      duration: 119,
    ),
    MovieModelCheryl(
      movieID: 'mv07',
      title: 'Demon Slayer: Kimestsu no Yaiba - The Movie: Infinity Castle',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/id/2/22/Kimetsu_no_Yaiba_Mugen_Jo_Hen_Poster.jpg',
      basePrice: 50000,
      rating: 4.9,
      duration: 117,
    ),
    MovieModelCheryl(
      movieID: 'mv08',
      title: 'Spider-Man : No Way Home',
      posterUrl: 'https://image.tmdb.org/t/p/original/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
      basePrice: 50000,
      rating: 4.9,
      duration: 150,
    ),
    MovieModelCheryl(
      movieID: 'mv09',
      title: 'Avengers: Endgame',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/id/0/0d/Avengers_Endgame_poster.jpg',
      basePrice: 50000,
      rating: 4.8,
      duration: 180,
    ),
    MovieModelCheryl(
      movieID: 'mv10',
      title: 'KKN di Desa Penari',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/id/b/b7/KKN_di_Desa_Penari.jpg',
      basePrice: 35000,
      rating: 4.3,
      duration: 180,
    ),
  ];

  Future<void> seedMovies() async {
    final CollectionReference movieRef = FirebaseFirestore.instance.collection('movies');

    try {
      print("Memulai proses seeding...");

      for (var movie in _moviesData) {
        await movieRef.doc(movie.movieID).set(movie.toMap_Cheryl());

        print("berhasil upload: ${movie.title}");
      }
      print("10 data dilm berhasil seed ke database");
    } catch (e) {
      print("Gagal seeding: $e");
    }
  }
}