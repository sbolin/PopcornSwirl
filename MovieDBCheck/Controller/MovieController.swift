//
//  MovieController.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/28/20.
//

import Foundation

class MovieController {
    
    struct Movie: Hashable, Identifiable { // Domain model used in App
        
        let id: Int
        let title: String
        let overview: String
        let genreID: [Int]
        let releaseDate: Date
        let voteAverage: Double
        let voteCount: Int
        let adult: Bool
        let video: Bool
        let popularity: Double
        let posterPath: String
        let backdropPath: String
        
        // actor data
        let actor: [String] = []
        let director: String = ""
        
        // company data
        let company: [String] = []
        
        // user added data
        let bookmarked: Bool = false
        let watched: Bool = false
        let favorite: Bool = false
        let note: String = ""
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    struct MovieCollection: Hashable {
        let identifier = UUID()
        let genreID: Int
        let movies: [Movie]
        var genreName: String {
            return genres[genreID]!.rawValue
        }
        
        enum Sections: String, CaseIterable {
            case Adventure, Action, Animation, Comedy, Documentary, Drama, Family, Mystery, Thriller
        }
        
        let genres: [Int : Sections] = [
            12:    .Adventure,
            16:    .Animation,
            18:    .Drama,
            28:    .Action,
            35:    .Comedy,
            53:    .Thriller,
            99:    .Documentary,
            9648:  .Mystery,
            10751: .Family
        ]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
        
    var collections: [MovieCollection] {
        return _collections
    }
    
    init() {
        populateMovieData()
    }
    fileprivate var _collections = [MovieCollection]()
}

extension MovieController {
    func populateMovieData() {
        print("in populateMovieData")
        let page = 1
        
        let genres: [MovieCollection.Sections : Int] = [
            .Adventure   : 12,
            .Animation   : 16,
            .Drama       : 18,
            .Action      : 28,
            .Comedy      : 35,
            .Thriller    : 53,
            .Documentary : 99,
            .Mystery     : 9648,
            .Family      : 10751
        ]
        
        for section in MovieCollection.Sections.allCases  {
            let genreID = genres[section]!
            var movies = [MovieController.Movie]()
            MovieDBCheck.MovieServiceAPI.shared.fetchMovies(from: genreID, page: page) {
                (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
                switch result {
                    case .success(let response):
                        movies = MovieDTOMapper.map(response)
                        print("1. movie count: \(movies.count)")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                // if _collections.append is here, it is created properly but zeroed upon leaving closure
                self._collections.append(MovieCollection(genreID: genreID, movies: movies))
                print("2. movie count: \(movies.count)")
                print("2. _collections.count: \(self._collections.count)")
            }
            // if _collections.append is here, only genre info is ok (and collectionview shows sections), but no movies data
//            _collections.append(MovieCollection(genreID: genreID, movies: movies))
            print("3. movie count: \(movies.count)")
            print("3. Section \(section)/\(genreID), movie count = \(movies.count)")
            print("3. _collections count: \(_collections.count)")
        }
    }
}
