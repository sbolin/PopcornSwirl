//
//  MovieController.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/28/20.
//

import UIKit

class MovieController {
    
    typealias MovieAPI = MovieDBCheck.MovieServiceAPI
    
    var moviesOld = [MovieListData]() // keep old movies def until change to MovieController is complete
    //    var movies = [MovieController.Movie]()
    
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
            case Adventure, Action, Animation, Comedy, Documentary, Drama, Family, Mystery, Thriller
        }
        
        func getGenreName(genreID: Int) -> String {
            
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
            
            return genres[genreID]!.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    struct GenreCollections {
        
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
        
        for section in MovieCollection.Sections.allCases {
            let genreID = genres[section]! // force unwrap dictionary, ok as genres is clearly defined above
            MovieAPI.shared.fetchMovies(from: genreID, page: page) {
                (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
                switch result {
                    case .success(let response):
                        let movieList: [Movie] = MovieDTOMapper.map(response)
                        for var movieItem in movieList {
                            
                            MovieAPI.shared.fetchCast(movieID: movieItem.id) { (result: Result<CastResponse, MovieServiceAPI.APIServiceError>) in
                                switch result {
                                    case .success(let cast):
                                        let cast: CastData = CastDTOMapper.map(dto: cast)
                                        let actor: [String] = cast.actor
                                        let director: String = cast.director
                                        movieItem.actor = actor
                                        movieItem.director = director
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                }
                            }
                            
                            MovieAPI.shared.fetchCompany(movieID: movieItem.id) { (result: Result<CompanyResponse, MovieServiceAPI.APIServiceError>) in
                                switch result {
                                    case .success(let company):
                                        let company: CompanyData = CompanyDTOMapper.map(company)
                                        let companyList: [String] = company.company
                                        movieItem.company = companyList
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                }
                            }
                            
                            MovieAPI.shared.fetchImage(imageSize: "w780", imageEndpoint: movieItem.posterPath) { (success, error, image) in
                                if let image = image, error == nil, success {
                                    movieItem.posterImage = image
                                } else {
                                    print("error \(error.debugDescription)")
                                }
                            }
                            
                            MovieAPI.shared.fetchImage(imageSize: "w780", imageEndpoint: movieItem.backdropPath) { (success, error, image) in
                                if let image = image, error == nil, success {
                                    movieItem.backdropImage = image
                                } else {
                                    print("error \(error.debugDescription)")
                                }
                            }
                        }
                        self._collections.append(MovieCollection(genreID: genreID, movies: movieList))
                        print("1. genreID: \(genreID)")
                        print("1. section: \(section)")
                        print("1. movie count: \(movieList.count)")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                // if _collections.append is here, it is created properly but zeroed upon leaving closure
//                self._collections.append(MovieCollection(genreID: genreID, movies: movieList))
                
                //               print("2. movie count: \(list.count)")
                print("2. _collections.count: \(self._collections.count)")
                print("2. _collection: \(self._collections)") // _collection at this point is correct
            }
            // if _collections.append is here, only genre info is ok (and collectionview shows sections), but no movies data
//            self._collections.append(MovieCollection(genreID: genreID, movies: movieList))
            //            print("3. movie count: \(self.movies.count)")
            //            print("3. Section \(section)/\(genreID), movie count = \(self.movies.count)")
            print("3. _collections count: \(self._collections.count)")
            print("3. _collection: \(self._collections)") // _collection at this point is not correct
            
        }
    }
    
    func getCastData(movieID: Int) -> CastData? {
        var castData: CastData?
        MovieAPI.shared.fetchCast(movieID: movieID) { (result: Result<CastResponse, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let response):
                    //                    for cast in response.cast {
                    //                        print("Character: \(cast.character)")
                    //                        print("id: \(cast.id)")
                    //                        print("Actor: \(cast.name)")
                    //                        print("\n")
                    //                    }
                    //                    for crew in response.crew {
                    //                        print("Crew for movie 550")
                    //                        print("Position: \(crew.job)")
                    //                        print("id: \(crew.id)")
                    //                        print("Name: \(crew.name)")
                    //                        print("\n")
                    //                    }
                    castData = CastDTOMapper.map(dto: response)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        return castData
    }
    
    func getMovieFromID(movieID: Int) -> [MovieListData] {
        // call movieserviceapi to get single movie response
        MovieAPI.shared.fetchMovie(movieId: movieID) { (result: Result<MovieData, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let movie):
                    self.moviesOld = MovieDTOMapper.map(movie)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        return moviesOld
    }
    
    
    func getCompanyData(movieID: Int) -> CompanyData? {
        var companyData: CompanyData?
        MovieAPI.shared.fetchCompany(movieID: 550) { (result: Result<CompanyResponse, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let response):
                    //                    for company in response.productionCompanies {
                    //                        print("Company: \(company.name)")
                    //                        print("Company ID: \(company.id)")
                    //                        print("Country: \(company.originCountry)")
                    //                        print("\n")
                    //                    }
                    companyData = CompanyDTOMapper.map(response)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        return companyData
    }
    // https://image.tmdb.org/t/p/w780/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg
    func getImage(imageSize: String, imageEndpoint: String) -> UIImage? {
        var imageObject: UIImage?
        MovieServiceAPI.shared.fetchImage(imageSize: imageSize, imageEndpoint: imageEndpoint) { (success, error, image)  in
            if success {
                print("success getting image")
                imageObject = image
            } else {
                print("could not get image, error thrown \(error?.localizedDescription ?? "" )")
            }
        }
        return imageObject
    }
}
