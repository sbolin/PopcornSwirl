//
//  MovieController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/28/20.
//

import UIKit

class MovieController {
    
    typealias MovieAPI = PopcornSwirl.MovieServiceAPI
    
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
    
    var imageItem = ImageData(movieID: 0, imagePath: URL(string: "https://image.tmdb.org/t/p")!, image: UIImage(), imageType: 0)
    var imageList = Set<ImageData>()
        
    fileprivate var _collections = [MovieCollection]()
    var collections: [MovieCollection] {
        print("...collections updated...")
        return _collections
    }
    
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
    
    init() {
        populateMovieData()
        populateSupplementaryMovieData()
        compileMovieData()
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
        var movies: [Movie]
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

extension MovieController {
    
    func populateMovieData() {
        print("in populateMovieData")
        let page = 1
        
        for section in MovieCollection.Sections.allCases {
            let genreID = genresByName[section]! // force unwrap dictionary, ok as genres is clearly defined above
//            group.enter()
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
//            group.leave()
        } // section
    } // func
    
    func populateSupplementaryMovieData() {
        for movie in movieList {
  //          movieItem = movie
            
            let posterURL = getImageURL(imageSize: "w780", endPoint: movie.posterPath)
            populateMovieImages(movieID: movie.id, url: posterURL, group: group, imageType: 0)
            
            let backdropURL = getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
            populateMovieImages(movieID: movie.id, url: backdropURL, group: group, imageType: 1)
            
            let castURL = getCastURL(movieID: movie.id)
            populateCastData(castURL: castURL, group: group)

            let companyURL = getCompanyURL(movieID: movie.id)
            populateCompanyData(companyURL: companyURL, group: group)

        } // movie in movieList
    } // func
    
    func compileMovieData() {
        group.notify(queue: queue) {
            self._collections = self._collections.map { item in
                var actors = [""]
                var director = ""
                var item = item
                item.movies = item.movies.map { movie in
                    var movie = movie
                    let id = movie.id
                    let cast = self.castList.filter( {$0.movieID == id})
                    cast.forEach { castData in
                        actors = castData.actor
                        director = castData.director
                    }
                    let companies = self.companyList.filter( {$0.movieID == id}).flatMap( {return $0.company})
                    let posterImage = self.imageList.filter( {$0.movieID == id && $0.imageType == 0}).map({return $0.image})
                    let backdropImage = self.imageList.filter( {$0.movieID == id && $0.imageType == 1}).map({return $0.image})
                    
                    movie.actor = actors
                    movie.director = director
                    movie.company = companies
                    
                    movie.posterImage = posterImage[0]
                    movie.backdropImage = backdropImage[0]
                    return movie
                }
                return item
            }
        }
    }
                
    
    func populateMovieImages(movieID: Int, url: URL, group: DispatchGroup, imageType: Int) {
        let imageKey = "\(url)" as NSString
        
        if let imageCache = cache.object(forKey: imageKey) {
            // use the cached version if available
            print("use cached image")
            let imageData = ImageData(movieID: movieID, imagePath: url, image: imageCache, imageType: imageType)
            imageList.insert(imageData)
        } else {
            // fetch then store in the cache if not
            group.enter()
            MovieAPI.shared.getImage(with: url, group: group) { [weak self] (data, response, error) in
                if error == nil, let data = data, let image = UIImage(data: data) {
                    print("fetch image, save to cache for later use")
                    self?.cache.setObject(image, forKey: imageKey)
                    let imageData = ImageData(movieID: movieID, imagePath: url, image: image, imageType: imageType)
                    self?.imageList.insert(imageData)
                } // error
            } // getImage
            group.leave()
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

