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
    let cache = NSCache<NSString, UIImage>()
    
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
    
    var imageItem = ImageData(movieID: 0, imagePath: URL(string: "https://image.tmdb.org/t/p")!, image: UIImage(), imageType: 0)
    var imageList = Set<ImageData>()
     
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
    let genresByName: [MovieCollection.Sections : Int] = [
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
    struct MovieItem: Hashable, Identifiable { // Domain model used in App
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
    
    // collection of movies
    struct MovieCollection: Hashable {
        let identifier = UUID()
        let genreID: Int
        var movies: [MovieItem]
        var genreName: String {
            return getGenreName(genreID: genreID)
        }
        
        enum Sections: String, CaseIterable {
            case Action, Adventure, Drama, Comedy, Animation, Family, Mystery, Thriller, Upcoming
        }
        
        func getGenreName(genreID: Int) -> String {
            
            let genresByID: [Int : Sections] = [
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
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
}

extension MovieDataController {
    func populateMovieData() {
        print("in populateMovieData")
        let page = 1
        
        for section in MovieCollection.Sections.allCases {
            let genreID = genresByName[section]! // force unwrap dictionary, ok as genres is clearly defined above
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
    
    func getMovieImage(imageURL: URL, completion: @escaping (Bool, UIImage?) -> Void) {
        let session = URLSession(configuration: .default)
        let imageKey = "\(imageURL)" as NSString
        if let imageCache = cache.object(forKey: imageKey) {
            print("fetched image from cache")
            completion(true, imageCache)
        } else {
            let task = session.dataTask(with: imageURL) { (data, response, error) in
                if let data = data, error == nil,
                   let response = response as? HTTPURLResponse,
                   response.statusCode == 200 {
                    guard let image = UIImage(data: data) else {
                        completion(false, nil)
                        return
                    }
                    self.cache.setObject(image, forKey: imageKey)
                    completion(true, image)
                }
                else {
                    completion(false, nil)
                }
            }
            task.resume()
        }
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
    
    func getMovieCast(castURL: URL, completion: @escaping (Bool, CastData?) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: castURL) { (data, response, error) in
            if let data = data, error == nil,
               let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                do {
                    let values = try self.jsonDecoder.decode(CastResponse.self, from: data)
                    let cast = CastDTOMapper.map(dto: values)
                    completion(true, cast)
                } catch  {
                    completion(false, nil)
                }
            }
            else {
                completion(false, nil)
            }
        }
        task.resume()
    } // getMovieCast
    
    // company data
    func getCompanyURL(movieID: Int) -> URL {
        let compURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID))
        var urlComponents = URLComponents(url: compURL, resolvingAgainstBaseURL: true)! // <---!!
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        urlComponents.queryItems = [apiQuery]
        return urlComponents.url! // <---!!
    }
    
    func getMovieCompany(companyURL: URL, completion: @escaping (Bool, CompanyData?) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: companyURL) { (data, response, error) in
            if let data = data, error == nil,
               let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                do {
                    let values = try self.jsonDecoder.decode(CompanyResponse.self, from: data)
                    let company = CompanyDTOMapper.map(dto: values)
                    completion(true, company)
                } catch {
                    completion(false, nil)
                }
            }
            else {
                completion(false, nil)
            }
        }
        task.resume()
    }
    
//    func populateSupplementaryMovieData() {
//        print("populateSupplementaryMovieData")
//        print("movieList.count = \(movieList.count)")
//        for movie in movieList {
//
//            let posterURL = getImageURL(imageSize: "w780", endPoint: movie.posterPath)
//            populateMovieImages(movieID: movie.id, url: posterURL, group: group, imageType: 0)
//            print("posterURL: \(posterURL)")
//
//            let backdropURL = getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
//            populateMovieImages(movieID: movie.id, url: backdropURL, group: group, imageType: 1)
//            print("backdropURL: \(backdropURL)")
//
//            let castURL = getCastURL(movieID: movie.id)
//            populateCastData(castURL: castURL, group: group)
//            print("castURL: \(castURL)")
//
//            let companyURL = getCompanyURL(movieID: movie.id)
//            populateCompanyData(companyURL: companyURL, group: group)
//            print("companyURL: \(companyURL)")
//
//        } // movie in movieList
//    } // func
    
//    func compileMovieData() {
//        print("in compileMovieData")
//        print("_collections: \(_collections)")
// //       group.notify(queue: queue) {
//            self._collections = self._collections.map { item in
//                print("_collections.map {item}: \(item)")
//                var actors = [""]
//                var director = ""
//                var item = item
//                item.movies = item.movies.map { movie in
//                    print("item.movies.map {movie}: \(movie)")
//                    var movie = movie
//                    let id = movie.id
//                    let cast = self.castList.filter( {$0.movieID == id})
//                    cast.forEach { castData in
//                        actors = castData.actor
//                        director = castData.director
//                    }
//                    let companies = self.companyList.filter( {$0.movieID == id}).flatMap( {return $0.company})
//                    let posterImage = self.imageList.filter( {$0.movieID == id && $0.imageType == 0}).map({return $0.image})
//                    let backdropImage = self.imageList.filter( {$0.movieID == id && $0.imageType == 1}).map({return $0.image})
//
//                    movie.actor = actors
//                    movie.director = director
//                    movie.company = companies
//
//
//                    print("actors = \(actors)")
//                    print("director = \(director)")
//                    print("companies = \(companies)")
//                    print("posterImages: \(posterImage.count)")
//                    print("backdropImages: \(backdropImage.count)")
//
////                    movie.posterImage = posterImage[0]
////                    movie.backdropImage = backdropImage[0]
//                    return movie
//                } // item.movies.map
//                return item
//            } // _collections
////        } // group notify
//    }
}

