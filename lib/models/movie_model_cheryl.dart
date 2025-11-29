class MovieModelCheryl {
  final String movieID;
  final String title;
  final String posterUrl;
  final int basePrice;
  final double rating;
  final int duration;

  MovieModelCheryl({
    required this.movieID,
    required this.title,
    required this.posterUrl,
    required this.basePrice,
    required this.rating,
    required this.duration,
  });

  Map<String, dynamic> toMap_Cheryl() {
    return {
      'movie_id' : movieID,
      'title' : title,
      'poster_url' : posterUrl,
      'base_price' : basePrice,
      'rating' : rating,
      'duration' : duration,
    };
  }

  factory MovieModelCheryl.fromMap_Cheryl(Map<String, dynamic> map, String id) {
    return MovieModelCheryl(
      movieID: id,
       title: map['title'] ?? '', 
       posterUrl: map['poster_url'] ?? '', 
       basePrice: map['base_price']?.toInt() ?? 0, 
       rating: map['rating']?.toDouble() ?? 0.0, 
       duration: map['duration']?.toInt() ?? 0,
       );
  }

  Map<String, dynamic> toMapCheryl() {
    return {
      'title' : title,
      'posterUrl' : posterUrl,
      'basePrice' : basePrice,
      'rating' : rating,
      'duration' : duration
    };
  }
}