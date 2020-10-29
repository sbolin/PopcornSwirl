//
//  MovieServiceAPI.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/21/20.
//

import UIKit

class MovieServiceAPI {
    
    public static let shared = MovieServiceAPI()
    private init() {}
    private let urlSession = URLSession.shared
    
    private let baseURL = URL(string: "https://api.themoviedb.org/3")! // 4 does not work
    private let apiKey = "a042fdafc76ac6243a7d5c85b930f1f6"
    
    //Movie parameters
    private let language = "en-US"
    private let origLanguage = "en"
    private let sortBy = "vote_average.desc" // "release_date.desc"
    private let releaseDateGTE = "2019-01-01"
    private let releaseDateLTE = "2021-01-01"
    private let releaseType = 3
    private let voteCountGTE = 1000
    private let voteAverageGTE = 7
    
    //Cast parameters
    //apiKey
    // pass in movieID/credits
    
    //Company parameters
    // apiKey + language
    // pass in movieID
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    // Enum Endpoint
    enum Endpoint: String, CaseIterable {
        case nowPlaying = "now_playing"
        case upcoming = "upcoming"
        case popular = "popular"
        case topRated = "top_rated"
    }
    public enum APIServiceError: Error {
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case decodeError
    }
//    public func fetchMovies(from endpoint: Endpoint, result: @escaping (Result<MoviesResponse, APIServiceError>) -> Void) {
//        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(endpoint.rawValue)
//        fetchResources(url: movieURL, genre: 0, page: 1, completion: result)
//    }
    
    public func fetchMovies(from genre: Int, page: Int, result: @escaping (Result<MoviesResponse, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("discover").appendingPathComponent("movie")
        fetchResources(url: movieURL, genre: genre, page: page, completion: result)
    }
    
    
    public func fetchMovie(movieId: Int, result: @escaping (Result<MovieData, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieId))
        fetchResources(url: movieURL, genre: 0, page: 1, completion: result)
    }
    
    public func fetchCast(movieID: Int, result: @escaping (Result<CastResponse, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID)).appendingPathComponent("credits")
        fetchResources(url: movieURL, genre: 0, page: 1, completion: result)
    }
    
    public func fetchCompany(movieID: Int, result: @escaping (Result<CompanyResponse, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID))
        fetchResources(url: movieURL, genre: 0, page: 1, completion: result)
    }
    
    // fetchImage returns an UIImage object given an image size and imageURL
    public func fetchImage(imageSize: String, imageEndpoint: String, result: @escaping (Bool, Error?, UIImage?) -> Void) {
        let baseImageURL = URL(string: "https://image.tmdb.org/t/p")!
        let movieURL = baseImageURL.appendingPathComponent(imageSize).appendingPathComponent(imageEndpoint)
        print("image url: \(movieURL)")
        urlSession.dataTask(with: movieURL) { data, response, taskerror in
            DispatchQueue.main.async {
                if let data = data, taskerror == nil {
                    if let response = response as? HTTPURLResponse,
                       response.statusCode == 200 {
                        let artwork = UIImage(data: data)
                        result(true, nil, artwork)
                    } else {
                        print("url response error: \(response.debugDescription)")
                        result(false, nil, nil)
                    }
                } else {
                    print("taskerror thrown: \(taskerror.debugDescription)")
                    result(false, taskerror, nil)
                }
            } // DispatchQueue
        }.resume()
    }
    
    
    private func fetchResources<T: Decodable>(url: URL, genre: Int, page: Int, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(.invalidEndpoint))
            return
        }

        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        let languageQuery = URLQueryItem(name: "language", value: language)
        let origLanguageQuery = URLQueryItem(name: "with_original_language", value: origLanguage)
        let voteAverage = URLQueryItem(name: "vote_average.gte", value: "\(voteAverageGTE)")
        let voteCount = URLQueryItem(name: "vote_count.gte", value: "\(voteCountGTE)")
        let sort = URLQueryItem(name: "sort_by", value: sortBy)
        let adult = URLQueryItem(name: "include_adult", value: "false")
        let video = URLQueryItem(name: "include_video", value: "false")
        let page = URLQueryItem(name: "page", value: "\(page)")
        let primaryReleaseDataGTE = URLQueryItem(name: "primary_release_date.gte", value: releaseDateGTE)
        let primaryReleaseDataLTE = URLQueryItem(name: "primary_release_date.lte", value: releaseDateLTE)
        let release = URLQueryItem(name: "with_release_type", value: "\(releaseType)")
        let genreID = URLQueryItem(name: "genre", value: "\(genre)")
        print("in fetchResources, genre = \(genre)")
        
        let queryItems = [apiQuery, languageQuery, origLanguageQuery, voteAverage, voteCount, sort, adult, video, page, primaryReleaseDataGTE, primaryReleaseDataLTE, release, genreID]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        print("in fetchResources, url for dataTask: \(url)")
        urlSession.dataTask(with: url) { (result) in
            switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    do {
                        let values = try self.jsonDecoder.decode(T.self, from: data)
                        print("returning from dataTask closure for url: \(url)")
                        completion(.success(values))
                    } catch {
                        completion(.failure(.decodeError))
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                    completion(.failure(.apiError))
            }
        }.resume()
    }
}

extension URLSession {
    func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async { //
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
            } //
        }
    }
}



