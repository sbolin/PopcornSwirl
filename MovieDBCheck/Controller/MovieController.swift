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
    let queue = DispatchQueue.global(qos: .userInteractive)
    let cache = NSCache<NSString, UIImage>()
    
    private let baseURL = URL(string: "https://api.themoviedb.org/3")! // 4 does not work
    private let apiKey = "a042fdafc76ac6243a7d5c85b930f1f6"
    private let baseImageURL = URL(string: "https://image.tmdb.org/t/p")!
    
    var movieItem = Movie(id: 0, title: "", overview: "", genreID: [0], releaseDate: Date(), voteAverage: 0, voteCount: 0, adult: false, video: false, popularity: 0, posterPath: "", backdropPath: "")
    var movieList = [Movie]()
    
    var castItem = CastData(movieID: 0, actor: [""], director: "")
    var castList = Set<CastData>()
    
    var companyItem = CompanyData(movieID: 0, company: [""])
    var companyList = Set<CompanyData>()
    
    var imageItem = ImageData(movieID: 0, imagePath: URL(string: "https://image.tmdb.org/t/p")!, image: UIImage())
    var imageList = Set<ImageData>()
        
    fileprivate var _collections = [MovieCollection]()
    var collections: [MovieCollection] {
        print("...collections updated...")
        return _collections
    }
    
    init() {
        populateMovieData()
        populateSupplementaryMovieData()
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
// new call to getMovies
            MovieAPI.shared.getMovies(from: genreID, page: page, group: group) { [weak self] (result: Result<MoviesResponse, Error>) in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        self.movieList = MovieDTOMapper.map(response)
                        let collectionItem = MovieCollection(genreID: genreID, movies: self.movieList)
                        self._collections.append(collectionItem)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                } // switch result
            } // getMovies
        } // section
    } // func
    
    func populateSupplementaryMovieData() {
        for movie in movieList {
            movieItem = movie
            
            let castURL = getCastURL(movieID: movie.id)
            populateCastData(castURL: castURL, group: group)

            let companyURL = getCompanyURL(movieID: movie.id)
            populateCompanyData(companyURL: companyURL, group: group)

            let posterURL = getImageURL(imageSize: "w780", endPoint: movie.posterPath)
            populateMovieImages(movieID: movie.id, url: posterURL, group: group)
            
            let backdropURL = getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
            populateMovieImages(movieID: movie.id, url: backdropURL, group: group)
        } // movie in movieList
    } // func
    
    func populateMovieImages(movieID: Int, url: URL, group: DispatchGroup) {
        let imageKey = "\(url)" as NSString
//        let backdropKey = "\(backdropURL)" as NSString
        
        if let imageCache = cache.object(forKey: imageKey) {
            // use the cached version if available
            print("use cached image")
            self.movieItem.posterImage = imageCache
        } else {
            // fetch then store in the cache if not
            group.enter()
            URLSession.shared.dataTask(with: url) { [weak self]  (data, response, error) in
                if error == nil, let data = data, let image = UIImage(data: data) {
                    print("fetch image, save to cache for later use")
                    self?.cache.setObject(image, forKey: imageKey)
                    let imageData = ImageData(movieID: movieID, imagePath: url, image: image)
                    self?.imageList.insert(imageData)
                } // error
            }.resume() // dataTask
            group.leave()
//            MovieAPI.shared.getImage(with: posterURL, group: group) { (data, _, error) in
//                if error == nil, let data = data, let image = UIImage(data: data) {
//                    print("fetch image, save to cache for later use")
//                    self.cache.setObject(image, forKey: posterKey)
//                    self.movieItem.posterImage = image
//                } // error
//            } // getImage
        } // else
    } // retrieveMovieImages
    
    func populateCastData(castURL: URL, group: DispatchGroup) {
        MovieAPI.shared.getCast(with: castURL, group: group) { [weak self] (result: Result<CastResponse, Error>) in
            group.enter()
            switch result {
                case .success(let response):
                    let cast = CastDTOMapper.map(dto: response)
                    self?.castList.insert(cast)
                case .failure(let error):
                    print(error.localizedDescription)
            } // switch
            group.leave()
        } // getCast
    } // populateCastData
        
    func populateCompanyData(companyURL: URL, group: DispatchGroup) {
        MovieAPI.shared.getCompany(with: companyURL, group: group) { [weak self] (result: Result<CompanyResponse, Error>) in
            group.enter()
            switch result {
                case .success(let response):
                    let company = CompanyDTOMapper.map(dto: response)
                    self?.companyList.insert(company)
                case .failure(let error):
                    print(error.localizedDescription)
            } // switch
            group.leave()
        } // getCompany
    } // populateCompanyData

    
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

