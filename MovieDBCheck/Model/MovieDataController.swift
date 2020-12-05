//
//  MovieDataController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/28/20.
//

import UIKit

class MovieDataController {
    
    //MARK: - Properties
    
    typealias MovieAPI = PopcornSwirl.MovieServiceAPI
    
    // Dispatch
    let group = DispatchGroup()
    let queue = DispatchQueue.global(qos: .userInteractive)
    
    // API
    private let baseURL = URL(string: "https://api.themoviedb.org/3")! // 4 does not work
    private let apiKey = "a042fdafc76ac6243a7d5c85b930f1f6"
    private let baseImageURL = URL(string: "https://image.tmdb.org/t/p")!
    
    // Instantiate MovieList
    var movieList = [MovieItem]()
    
    var castItem = CastData(movieID: 0, actor: [""], director: "")
    var castList = Set<CastData>()
    
    var companyItem = CompanyData(movieID: 0, company: [""])
    var companyList = Set<CompanyData>()
    
//    var imageItem = ImageData(movieID: 0, imagePath: URL(string: "https://image.tmdb.org/t/p")!, image: UIImage(), imageType: 0)
//    var imageList = Set<ImageData>()
     
    // temporary collection
    fileprivate var _collections = [MovieCollection]()
    
    // calculated collection, updates with changes to _collections (used in diffabledatasource)
    var collections: [MovieCollection] {
        return _collections
    }
    
    // jsondecoder
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    // genres/sections
    let genresByName: [MovieCollection.Genres : Int] = [
        .Adventure   : 12,
        .Animation   : 16,
        .Drama       : 18,
        .Action      : 28,
        .Comedy      : 35,
        .Thriller    : 53,
        .Mystery     : 9648,
        .Family      : 10751,
        .Upcoming    : 99999
    ]
    
    init() {}
    
    // MovieItem struct
    struct MovieItem: Hashable, Identifiable {
        // Domain model used in App
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
        
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(id)
//        }
    }
    
    // collection of movies
struct MovieCollection: Hashable, Identifiable {
        let id = UUID()
        let genreID: Int
        var movies: [MovieItem]
        var genreName: String {
            return getGenreName(genreID: genreID)
        }
        
        enum Genres: String, Hashable, CaseIterable {
            case Action, Adventure, Drama, Comedy, Animation, Family, Mystery, Thriller, Upcoming
        }
        
        func getGenreName(genreID: Int) -> String {
            
            let genresByID: [Int : Genres] = [
                12:    .Adventure,
                16:    .Animation,
                18:    .Drama,
                28:    .Action,
                35:    .Comedy,
                53:    .Thriller,
                9648:  .Mystery,
                10751: .Family,
                99999: .Upcoming
            ]
            return genresByID[genreID]!.rawValue
        }
        
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(identifier)
//        }
    }
}

extension MovieDataController {
    func populateMovieData() {
        let page = 1

        for genre in MovieCollection.Genres.allCases {
            let genreID = genresByName[genre]! // force unwrap dictionary, ok as genres is clearly defined above
            MovieAPI.shared.getMovies(from: genreID, page: page) { [weak self] (result: Result<MoviesResponse, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                    case .success(let response):
                        strongSelf.movieList = MovieDTOMapper.map(response)
                        let collectionItem = MovieCollection(genreID: genreID, movies: strongSelf.movieList)
                        strongSelf._collections.append(collectionItem)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                } // switch result
            } // getMovies
        } // section
    } // func
    
    // images
    func getImageURL(imageSize: String, endPoint: String) -> URL {
        return baseImageURL.appendingPathComponent(imageSize).appendingPathComponent(endPoint)
    }
    
    //DANGER NOTE! urlComponents is unwrapped, possibly causing crash. Ask Peter about this
    // https://api.themoviedb.org/3/movie/###/credits?api_key=a042fdafc76ac6243a7d5c85b930f1f6
    // cast data
    func getCastURL(movieID: Int) -> URL {
        let castURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID)).appendingPathComponent("credits")
        var urlComponents = URLComponents(url: castURL, resolvingAgainstBaseURL: true)! // <---!!
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        urlComponents.queryItems = [apiQuery]
        return urlComponents.url! // <---!!
    }
    
    // company data
    func getCompanyURL(movieID: Int) -> URL {
        let compURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID))
        var urlComponents = URLComponents(url: compURL, resolvingAgainstBaseURL: true)! // <---!!
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        urlComponents.queryItems = [apiQuery]
        return urlComponents.url! // <---!!
    }
}

