//
//  MovieStore.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/18/20.
//

import UIKit

class MovieActions {
    
    static let shared = MovieActions()
    private init() {}
    
    private let apiKey = "a042fdafc76ac6243a7d5c85b930f1f6"
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let urlSession = URLSession.shared
    private let jsonDecoder = Utils.jsonDecoder
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    var movieList = [MovieDataStore.MovieItem]()
    fileprivate var localCollection = [MovieDataStore.MovieCollection]()
    var collections: [MovieDataStore.MovieCollection] {
        return localCollection
    }
    
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    // fetch movies at given endpoint
    func fetchMovies(from endpoint: MovieListEndpoint, completion: @escaping (Result<MovieResponse, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/movie/\(endpoint.rawValue)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, completion: completion)
    }
    // MARK: - Movie fetch Methods
    
    // MARK:  Fetch Movies by genre
    /// Fetch Movies by Genre
    /// - Parameters:
    ///   - genre: movie genre type, per TMDB API spec
    ///   - completion: Result closure
    /// - Returns: Movie data for movies in genre
    func fetchMoviesByGenre(from genre: Int, completion: @escaping (Result<MovieResponse, MovieError>) -> ()) {
        var url = baseURL.appendingPathComponent("discover").appendingPathComponent("movie")
        
        var params = [
            "language" : "en-US",
            "with_original_language" : "en",
            "region" : "US",
            "include_adult" : "false",
            "vote_average.gte" : "7.0",
            "vote_count.gte" : "1000",
            "sort_by" : "vote_average.desc",
            "include_video" :  "false",
            "primary_release_date.gte" : "2019-06-01",
            "primary_release_date.lte" : "2021-01-31",
            "with_release_type" : "3",
            "with_genres" : "\(genre)"
        ]
        if genre == 99998 {
            url = baseURL.appendingPathComponent("movie").appendingPathComponent("upcoming")
            params = [:]
        }
        if genre == 99999 {
            url = baseURL.appendingPathComponent("movie").appendingPathComponent("popular")
            params = [:]
        }
        self.loadURLAndDecode(url: url, params: params,
                              completion: completion)
    }
    
    //MARK: Fetch Movie by id
    /// Fetch individual movie for detail view
    /// - Parameters:
    ///   - id: Movie id parameter (Int)
    ///   - completion: Result closure
    /// - Returns: Movie data for movie id
    func fetchMovie(id: Int, completion: @escaping (Result<SingleMovie, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/movie/\(id)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, params: [
            "append_to_response" : "videos,credits"
        ],
        completion: completion)
    }
    
    //MARK:  Search for movie using keyword
    /// Search for movie by keyword
    /// - Parameters:
    ///   - query: search keyword (String)
    ///   - completion: Result closure
    /// - Returns: Movies containing keyword
    func searchMovie(query: String, completion: @escaping (Result<MovieResponse, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/search/movie") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, params: [
            "language" : "en-US",
            "include_adult" : "false",
            "region" : "US",
            "query" : query
        ],
        completion: completion)
    }
    
    //MARK: Fetch/cache movie Image
    /// Fetch movie poster image
    /// - Parameters:
    ///   - imageURL: URL for image (URL included in movie fetch result)
    ///   - completion: Result closure containing image data
    /// - Returns: UIImage, stores image in cache with URL as key
    func fetchImage(imageURL: URL, completion: @escaping (Bool, UIImage?) -> ()) {
        let imageKey = "\(imageURL)" as NSString
        if let imageCache = imageCache.object(forKey: imageKey) {
            completion(true, imageCache)
        } else {
            urlSession.dataTask(with: imageURL) { (data, response, error) in
                if let data = data, error == nil,
                   let response = response as? HTTPURLResponse,
                   response.statusCode == 200 {
                    guard let image = UIImage(data: data) else {
                        completion(false, nil)
                        return
                    }
                    DispatchQueue.main.async {
                        self.imageCache.setObject(image, forKey: imageKey)
                        completion(true, image)
                    }
                }
                else {
                    completion(false, nil)
                }
            }.resume()
        }
    }
    
    //MARK: Initial movie loader
    // load movie data from tmdb API to Core Data
    /// Initial Movie fetch
    /// - Parameter completion: completion handler
    /// - Returns: [MovieCollection]
    func loadMovieData(completion: @escaping ([MovieDataStore.MovieCollection]?) -> ()) {
        var loadedData = false
        
        // option fetch by genre
        for genre in MovieDataStore.MovieCollection.Genres.allCases {
            self.group.enter()
            fetchMoviesByGenre(from: genre.rawValue) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        loadedData = true
                        self.movieList = MoviesDTOMapper.map(response)
                        let collectionItem = MovieDataStore.MovieCollection(genreID: genre.rawValue, movies: self.movieList)
                        self.localCollection.append(collectionItem)
                    case .failure(let error):
                        print("Error loading \(genre): \(error.localizedDescription)")
                        loadedData = false
                }
                self.group.leave()
            }
        }
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                if loadedData {
                    completion(localCollection)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: Generic helper load and decode data
    /// Generic Helper method to fetch data from endpoint
    /// - Parameters:
    ///   - url: URL of endpoint with data to fetch
    ///   - params: Dictionary containing URLQueryItems
    ///   - completion: Result closure
    /// - Returns: Generic data response
    private func loadURLAndDecode<T: Decodable>(url: URL, params: [String: String]? = nil, completion: @escaping (Result<T, MovieError>) -> ()) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        
        urlComponents.queryItems = queryItems
        
        guard let finalURL = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        urlSession.dataTask(with: finalURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                self.executeCompletionHandlerInMainThread(with: .failure(.apiError), completion: completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.executeCompletionHandlerInMainThread(with: .failure(.invalidResponse), completion: completion)
                return
            }
            
            guard let data = data else {
                self.executeCompletionHandlerInMainThread(with: .failure(.noData), completion: completion)
                return
            }
            
            do {
                let decodedResponse = try self.jsonDecoder.decode(T.self, from: data)
                self.executeCompletionHandlerInMainThread(with: .success(decodedResponse), completion: completion)
            } catch {
                self.executeCompletionHandlerInMainThread(with: .failure(.decodeError), completion: completion)
            }
        }.resume()
    }
    
    //MARK: Helper method execute result on main thread
    /// Execute Completion Handler on my thread
    /// - Parameters:
    ///   - result: pass in result to put on main thread
    ///   - completion: Result closure
    /// - Returns: <#description#>
    private func executeCompletionHandlerInMainThread<D: Decodable>(with result: Result<D, MovieError>, completion: @escaping (Result<D, MovieError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
