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
    let queue = DispatchQueue.global(qos: .utility)
    
    private let baseURL = URL(string: "https://api.themoviedb.org/3")! // 4 does not work
    private let apiKey = "a042fdafc76ac6243a7d5c85b930f1f6"
    private let baseImageURL = URL(string: "https://image.tmdb.org/t/p")!
    
    var movieItem = Movie(id: 0, title: "", overview: "", genreID: [0], releaseDate: Date(), voteAverage: 0, voteCount: 0, adult: false, video: false, popularity: 0, posterPath: "", backdropPath: "")
    var movieList = [Movie]()
    
    var castItem = CastData(movieID: 0, actor: [""], director: "")
    var castList = Set<CastData>()
    var companyItem = CompanyData(movieID: 0, company: [""])
    var companyList = Set<CompanyData>()
        
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
            case Action, Adventure, Drama, Comedy, Animation, Family, Mystery, Thriller, Upcoming
        }
        
        func getGenreName(genreID: Int) -> String {
            
            let genres: [Int : Sections] = [
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
            .Mystery     : 9648,
            .Family      : 10751,
            .Upcoming    : 99999
        ]
        
        for section in MovieCollection.Sections.allCases {
            let genreID = genres[section]! // force unwrap dictionary, ok as genres is clearly defined above
            print("0. Genre: \(section)/\(genreID)")
// new call to getMovies
            MovieAPI.shared.getMovies(from: genreID, page: page, group: group) { (result: Result<MoviesResponse, Error>) in
                switch result {
                    case .success(let response):
                        self.movieList = MovieDTOMapper.map(response)
                        let collectionItem = MovieCollection(genreID: genreID, movies: self.movieList)
//                        self.group.notify(queue: self.queue) {
                        self._collections.append(collectionItem)
//                        } // group.notify
                        
                        print("1. Movie Genre: \(section)/\(genreID)")
                        print("1. movieList.count       = \(self.movieList.count)")
                        print("1. _collections.count    = \(self._collections.count)")
                        print("1. collections.count     = \(self.collections.count)")
                        for movie in self.movieList {
                            self.movieItem = movie
                            let posterURL = getImageURL(imageSize: "w780", endPoint: movie.posterPath)
                            let backdropURL = getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
                            let castURL = getCastURL(movieID: movie.id)
                            let companyURL = getCompanyURL(movieID: movie.id)
                            retrieveMovieImages(posterURL: posterURL, backdropURL: backdropURL, group: self.group)
                            print("for movie in movieList:")
                            print("Movie Title:   \(movie.title)")
                            print("posterURL:     \(self.movieItem.posterPath)")
                            print("posterImage:   \(self.movieItem.posterImage)")
                            print("backdropURL:   \(self.movieItem.backdropPath)")
                            print("backdropImage: \(self.movieItem.backdropImage)\n")
                            retrieveSupplimentalMovieData(castURL: castURL, companyURL: companyURL, group: self.group)
// _collections.append: created properly but sections/data not shown in collectionView
//                          self.group.notify(queue: self.queue) {
//                          self._collections.append(MovieCollection(genreID: genreID, movies: self.movieList))
//                          } // notify
                        } // movie in movieList
                    case .failure(let error):
                        print(error.localizedDescription)
                } // switch result
// _collections.append: created properly but sections/data not shown in collectionView
//              self.group.notify(queue: self.queue) {
//              print("2. group.notify called")
//              self._collections.append(MovieCollection(genreID: genreID, movies: self.movieList))
                print("2. exited switch result")
                print("2. movieList count:        \(self.movieList.count)")
                print("2. _collections.count:     \(self._collections.count)")
                print("2. collections.count:      \(self.collections.count)\n")
//              } // notify
            } // getMovies
        } // section

        func retrieveMovieImages(posterURL: URL, backdropURL: URL, group: DispatchGroup) {
            
            let cache = NSCache<NSString, UIImage>()
            let posterKey = "\(posterURL)" as NSString
            let backdropKey = "\(backdropURL)" as NSString
            
            if let posterCache = cache.object(forKey: posterKey) {
                // use the cached version
                self.movieItem.posterImage = posterCache
            } else {
                // create it from scratch then store in the cache
                MovieAPI.shared.getImage(with: posterURL, group: group) { (data, _, error) in
                    if error == nil, let data = data, let image = UIImage(data: data) {
                        cache.setObject(image, forKey: posterKey)
                        self.movieItem.posterImage = image
                    }
                }
            }
            
            if let backdropCache = cache.object(forKey: backdropKey) {
                // use the cached version
                self.movieItem.posterImage = backdropCache
            } else {
                // create it from scratch then store in the cache
                MovieAPI.shared.getImage(with: backdropURL, group: group) { (data, _, error) in
                    if error == nil, let data = data, let image = UIImage(data: data) {
                        cache.setObject(image, forKey: backdropKey)
                        self.movieItem.backdropImage = image
                    }
                }
            }
        }
    
        func retrieveSupplimentalMovieData(castURL: URL, companyURL: URL, group: DispatchGroup) {
            MovieAPI.shared.getCast(with: castURL, group: group) { (result: Result<CastResponse, Error>) in
                switch result {
                    case .success(let response):
                        let cast = CastDTOMapper.map(dto: response)
                        self.castList.insert(cast)
                        print("getCast inserted:")
                        print("getCast movieID:   \(cast.movieID)")
                        print("getCast actors:    \(cast.actor)")
                        print("getCast directors: \(cast.director)\n")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        
            MovieAPI.shared.getCompany(with: companyURL, group: group) { (result: Result<CompanyResponse, Error>) in
                switch result {
                    case .success(let response):
                        let company = CompanyDTOMapper.map(dto: response)
                        self.companyList.insert(company)
                        print("getCompany inserted:")
                        print("getCompany movieID:  \(company.movieID)")
                        print("getCompany companies: \(company.company)\n")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
        
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
}
