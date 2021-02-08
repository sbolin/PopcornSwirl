//
//  MovieStore.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/18/20.
//

import UIKit

/// Setup tMDB API properties and movie fetch methods
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
    
    typealias ImageHandler = (Result<UIImage, ImageLoadingError>) -> ()
    typealias LoadMovieHandler = (Result<[MovieDataStore.MovieCollection], MovieError>) -> ()
    typealias FetchMovieHandler = (Result<MovieResponse, MovieError>) -> ()
    typealias FetchSingleMovieHandler = (Result<SingleMovieResponse, MovieError>) -> ()
    typealias SearchMovieHandler = (Result<SearchMovieResponse, MovieError>) -> ()

    
    //MARK: Initial movie loader
    // load movie data from tmdb API to Core Data
    /// Initial Movie fetch
    /// - Parameter completion: completion handler
    /// - Returns: [MovieCollection]
    func loadMovieData(completion: @escaping LoadMovieHandler) {
        var loadedData = false
        
        // option fetch by genre
        for genre in MovieDataStore.MovieCollection.Genres.allCases {
            print("loadMovieData, genre: \(genre)")
            self.group.enter()
            fetchMoviesByGenre(from: genre.rawValue) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        self.movieList = MoviesDTOMapper.map(response)
                        let collectionItem = MovieDataStore.MovieCollection(genreID: genre.rawValue, movies: self.movieList)
                        self.localCollection.append(collectionItem)
                        loadedData = true
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
                    completion(.success(localCollection)) //
                } else {
                    completion(.failure(.apiError)) //
                }
            }
        }
    }
    
    // MARK: Fetch moves at endpoint
    /// Fetch movies at a given endpoint
    /// - Parameters:
    ///   - endpoint: MovieListEndpoint, such as nowPlaying, upcoming, topRated, popular
    ///   - completion: Result closure with response or error returned
    /// - Returns: Movie data for movies at endpoint (returns data for multiple movies)
    func fetchMovies(from endpoint: MovieListEndpoint, completion: @escaping FetchMovieHandler) {
        guard let movieURL = URL(string: "\(baseURL)/movie/\(endpoint.rawValue)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        fetchResources(url: movieURL, completion: completion) // loadURLAndDecode
    }
    
    // MARK: Fetch Movies by genre
    /// Fetch Movies by Genre
    /// - Parameters:
    ///   - genre: movie genre type, per TMDB API spec
    ///   - completion: Result closure with response or error returned
    /// - Returns: Movie data for movies in genre
    func fetchMoviesByGenre(from genre: Int, completion: @escaping FetchMovieHandler) {
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
        let finalURL = makeURL(url: url, params: params)
        fetchResources(url: finalURL, completion: completion) // loadURLAndDecode
    }
    
    // MARK: Fetch Movie by id
    /// Fetch individual movie for detail view
    /// - Parameters:
    ///   - id: Movie id parameter (Int)
    ///   - finalURL: URL to submit to API to fetch movie
    ///   - completion: Result closure
    /// - Returns: Movie data for movie id (returns data for a single movie)
    func fetchMovie(id: Int, completion: @escaping FetchSingleMovieHandler) {
        guard let url = URL(string: "\(baseURL)/movie/\(id)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        let params = ["append_to_response" : "videos,credits"]
        let finalURL = makeURL(url: url, params: params)
        fetchResources(url: finalURL, completion: completion)  // loadURLAndDecode
    }
    
    // MARK:  Search for movie using keyword
    /// Search for movie by keyword
    /// - Parameters:
    ///   - query: search keyword (String)
    ///   - completion: Result closure
    /// - Returns: Movies containing keyword
    func searchMovie(query: String, completion: @escaping FetchMovieHandler) { // SearchMovieHandler
        guard let url = URL(string: "\(baseURL)/search/movie") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        let params = ["original_language": "en", "language" : "en-US", "include_adult" : "false", "region" : "US", "query" : query]
        let finalURL = makeURL(url: url, params: params)
        fetchResources(url: finalURL, completion: completion)  // loadURLAndDecode
    }
    
    // MARK: Fetch/cache movie Image
    /// Fetch movie poster image
    /// - Parameters:
    ///   - imageURL: URL for image (URL included in movie fetch result)
    ///   - completion: Result closure containing image data
    /// - Returns: UIImage, stores image in cache with URL as key
    func fetchImage(at imageURL: URL, completion: @escaping ImageHandler) {
        let imageKey = "\(imageURL)" as NSString
        if let imageCache = imageCache.object(forKey: imageKey) {
            completion(.success(imageCache))
        } else {
            urlSession.dataTask(with: imageURL) { result in
                switch result {
                    case .success(let (response, data)):
                        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                            completion(.failure(.invalidResponse))
                            return
                        }
                        guard let image = UIImage(data: data) else {
                            completion(.failure(.invalidData))
                            return
                        }
                        DispatchQueue.main.async {
                            self.imageCache.setObject(image, forKey: imageKey)
                            completion(.success(image))
                        } // DispatchQueue
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                        completion(.failure(.networkFailure(error)))
                } // switch
            } // dataTask
            .resume()
        } // else
    } // fetchImage
    
    // MARK: - Helper Methods
    // helper method to construct URL given base url and parameters
    private func makeURL(url: URL, params: [String: String]? = nil) -> URL {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents?.queryItems = queryItems
        guard let finalURL = urlComponents?.url else {
            return url
        }
        return finalURL
    }
    
    // generic function called to fetch data from URL and pass back Result handler closure
    private func fetchResources<T: Decodable>(url: URL, completion: @escaping (Result<T, MovieError>) -> ()) {
        urlSession.dataTask(with: url) { result in
            switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                        //                        self.executeCompletionHandlerInMainThread(with: .failure(.invalidResponse), completion: completion)
                        completion(.failure(.invalidResponse))
                        return
                    }
                    do {
                        let values = try self.jsonDecoder.decode(T.self, from: data)
                        //                        self.executeCompletionHandlerInMainThread(with: .success(values), completion: completion)
                        completion(.success(values))
                    } catch {
                        //                        self.executeCompletionHandlerInMainThread(with: .failure(.decodeError), completion: completion)
                        completion(.failure(.decodeError))
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                    //                    self.executeCompletionHandlerInMainThread(with: .failure(.apiError), completion: completion)
                    completion(.failure(.apiError))
            }
        }.resume()
    }
    
    //MARK: Helper method execute result on main thread
    /// Execute Completion Handler on the main thread
    /// - Parameters:
    ///   - result: pass in result to put on main thread
    ///   - completion: Result closure
    /// - Returns: closure
    private func executeCompletionHandlerInMainThread<D: Decodable>(with result: Result<D, MovieError>, completion: @escaping (Result<D, MovieError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

// MARK: - URLSession Extension Methods
extension URLSession {
    func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> ()) -> URLSessionDataTask {
        return dataTask(with: url) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}
