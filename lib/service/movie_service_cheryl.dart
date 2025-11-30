import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model_cheryl.dart';

class MovieServiceCheryl {
  Future<List<MovieModelCheryl>> fetchAllMovies_Cheryl() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('movies').get();

      return snapshot.docs.map((doc) {
        return MovieModelCheryl.fromMap_Cheryl(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print("Error fetching movies: $e");
      return [];
    }
  }
}