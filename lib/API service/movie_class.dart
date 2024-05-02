class Movie {
  final int id;
  final String title;
  final String poster;

  Movie({required this.id, required this.title, required this.poster});
}

class DetailedMovie extends Movie {
  final String overview;
  final double rating;
  final List<String> genres;
  final int releaseYear;
  final String director;
  final String certification; 
  final List<String> productionCountries; 
  final String productionStudio; 

  DetailedMovie({
    required int id,
    required String title,
    required String poster,
    required this.overview,
    required this.rating,
    required this.genres,
    required this.releaseYear,
    required this.director,
    required this.certification,
    required this.productionCountries,
    required this.productionStudio,
  }) : super(id: id, title: title, poster: poster);
}
