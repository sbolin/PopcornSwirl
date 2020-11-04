//
//  MovieController.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/28/20.
//

import UIKit

class MovieController {
    
    typealias MovieAPI = MovieDBCheck.MovieServiceAPI
    
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    var moviesOld = [MovieListData]() // keep old movies def until change to MovieController is complete
    //    var movies = [MovieController.Movie]()
    
    var movieItem = Movie(id: 0, title: "", overview: "", genreID: [0], releaseDate: Date(), voteAverage: 0, voteCount: 0, adult: false, video: false, popularity: 0, posterPath: "", backdropPath: "")
    var movieList = [Movie]()
    fileprivate var _collections = [MovieCollection]()
    var collections: [MovieCollection] {
        print("...collections updated...")
        return _collections
    }
    
    init() {
        populateMovieData()
    }
    
    struct Movie: Hashable, Identifiable { // Domain model used in App
        
        var id: Int
        var title: String
        var overview: String
        var genreID: [Int]
        var releaseDate: Date
        var voteAverage: Double
        var voteCount: Int
        var adult: Bool
        var video: Bool
        var popularity: Double
        var posterPath: String
        var posterImage = UIImage()
        var backdropPath: String
        var backdropImage = UIImage()
        
        // actor data
        var actor: [String] = []
        var director: String = ""
        
        // company data
        var company: [String] = []
        
        // user added data
        var bookmarked: Bool = false
        var watched: Bool = false
        var favorite: Bool = false
        var note: String = ""
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    struct MovieCollection: Hashable {
        let identifier = UUID()
        let genreID: Int
        let movies: [Movie]
        var genreName: String {
            return getGenreName(genreID: genreID)
        }
        
        enum Sections: String, CaseIterable {
            case Adventure, Action, Animation, Comedy, Drama, Family, Mystery, Thriller
//            case Adventure, Action, Animation, Comedy, Documentary, Drama, Family, Mystery, Thriller
        }
        
        func getGenreName(genreID: Int) -> String {
            
            let genres: [Int : Sections] = [
                12:    .Adventure,
                16:    .Animation,
                18:    .Drama,
                28:    .Action,
                35:    .Comedy,
                53:    .Thriller,
  //              99:    .Documentary,
                9648:  .Mystery,
                10751: .Family
            ]
            
            return genres[genreID]!.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
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
//            .Documentary : 99,
            .Mystery     : 9648,
            .Family      : 10751
        ]
        
        for section in MovieCollection.Sections.allCases {
            let genreID = genres[section]! // force unwrap dictionary, ok as genres is clearly defined above
            MovieAPI.shared.fetchMovies(from: genreID, page: page, group: group) {
                (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
                switch result {
                    case .success(let response):
                        self.movieList = MovieDTOMapper.map(response)
                        for item in self.movieList {
                            self.movieItem = item
                            
                            MovieAPI.shared.fetchCast(movieID: item.id, group: self.group) { (result: Result<CastResponse, MovieServiceAPI.APIServiceError>) in
                                switch result {
                                    case .success(let response):
                                        let cast = CastDTOMapper.map(dto: response)
                                        self.movieItem.actor = cast.actor
                                        self.movieItem.director = cast.director
                                        
                                        print("Genre: \(section)/\(genreID)")
                                        print("movie: \(item.title)")
                                        print("movie ID: \(item.id)")
                                        print("cast: \(self.movieItem.actor)")
                                        print("director: \(self.movieItem.director)")
                                    case .failure(let error):
                                        print("localized error: \(error.localizedDescription)")
                                }
                            }
                            
                            MovieAPI.shared.fetchCompany(movieID: item.id, group: self.group) { (result: Result<CompanyResponse, MovieServiceAPI.APIServiceError>) in
                                switch result {
                                    case .success(let response):
                                        let company = CompanyDTOMapper.map(dto: response)
                                        let companyList = company.company
                                        self.movieItem.company = companyList
                                        
                                        print("company: \(self.movieItem.company)")
                                    case .failure(let error):
                                        print("localized error: \(error.localizedDescription)")
                                }

                            }
                            
                            MovieAPI.shared.fetchImage(imageSize: "w780", imageEndpoint: item.posterPath, group: self.group) { (success, error, image) in
                                if let image = image, error == nil, success {
                                    self.movieItem.posterImage = image
                                } else {
                                    print("error \(error.debugDescription)")
                                }
                            }
                            
                            MovieAPI.shared.fetchImage(imageSize: "w780", imageEndpoint: item.backdropPath, group: self.group) { (success, error, image) in
                                if let image = image, error == nil, success {
                                    self.movieItem.backdropImage = image
                                } else {
                                    print("error \(error.debugDescription)")
                                }
                            }
                            print("0. genre: \(section) ")
                            print("0. movieItem name: \(self.movieItem.title)")
                            print("0. movieItem actor: \(self.movieItem.actor)")
                            print("0. movieItem director: \(self.movieItem.director)")
                            print("0. movieItem company: \(self.movieItem.company)")
                            print("0. movieItem posterImage: \(self.movieItem.posterImage)")
                            print("0. movieItem backdropImage: \(self.movieItem.backdropImage)")
                            print("0. movieList count: \(self.movieList.count)")

                        }
//                      self._collections.append(MovieCollection(genreID: genreID, movies: self.movieList))
                        print("1. genreID: \(genreID)")
                        print("1. genre: \(section)")
                        print("1. movieList count: \(self.movieList.count)")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                self.group.notify(queue: self.queue) {
                    print("in group notify")
// if _collections.append is here, it is created properly but zeroed upon leaving closure
                self._collections.append(MovieCollection(genreID: genreID, movies: self.movieList))
                print("2. _collections.count: \(self._collections.count)")
                print("2. _collection: \(self._collections)") // _collection at this point is correct
                print("2. collection: \(self.collections.count)")
                print("2. collection: \(self.collections)") // _collection at this point is not correct
            }
// if _collections.append is here, only genre info is ok (and collectionview shows sections), but no movie data
//            self._collections.append(MovieCollection(genreID: genreID, movies: movieList))
            print("3. section: \(section)/\(genreID)")
                print("3. movieList count: \(self.movieList.count)")
            print("3. _collections count: \(self._collections.count)")
            print("3. _collection: \(self._collections)") // _collection at this point is not correct
            print("3. collection: \(self.collections.count)")
            print("3. collection: \(self.collections)") // _collection at this point is not correct
            }
        }
    }
    
    func getMovieFromID(movieID: Int) -> [MovieListData] {
        // call movieserviceapi to get single movie response
        MovieAPI.shared.fetchMovie(from: movieID, group: group) { (result: Result<MovieData, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let movie):
                    self.moviesOld = MovieDTOMapper.map(movie)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        return moviesOld
    }
    
    // https://image.tmdb.org/t/p/w780/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg
//    func getImage(imageSize: String, imageEndpoint: String) -> UIImage? {
//        var imageObject: UIImage?
//        MovieServiceAPI.shared.fetchImage(imageSize: imageSize, imageEndpoint: imageEndpoint) { (success, error, image)  in
//            if success {
//                print("success getting image")
//                imageObject = image
//            } else {
//                print("could not get image, error thrown \(error?.localizedDescription ?? "" )")
//            }
//        }
//        return imageObject
//    }
}
