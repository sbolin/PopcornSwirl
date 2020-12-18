//
//  MovieStore.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/18/20.
//

import UIKit

class MovieStore: MovieService {
    
    static let shared = MovieStore()
    private init() {}
    
    private let apiKey = "a042fdafc76ac6243a7d5c85b930f1f6"
    private let baseURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    private let jsonDecoder = Utils.jsonDecoder
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    // fetch movies at given endpoint
    func fetchMovies(from endpoint: MovieListEndpoint, completion: @escaping (Result<MovieResponse, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/movie/\(endpoint.rawValue)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, completion: completion)
    }
    
    // fetch individual movie for detail view
    func fetchMovie(id: Int, completion: @escaping (Result<MovieData, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseURL)/movie/\(id)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, params: [
            "append_to_response" : "videos,credits"
        ],
        completion: completion)
    }
    
    // search for movie using keyword
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
    
    func fetchImage(imageURL: URL, completion: @escaping (Bool, UIImage?) -> Void) {
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
    
    private func loadURLAndDecode<D: Decodable>(url: URL, params: [String: String]? = nil, completion: @escaping (Result<D, MovieError>) -> ()) {
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
                let decodedResponse = try self.jsonDecoder.decode(D.self, from: data)
                self.executeCompletionHandlerInMainThread(with: .success(decodedResponse), completion: completion)
            } catch {
                self.executeCompletionHandlerInMainThread(with: .failure(.decodeError), completion: completion)
            }
        }.resume()
    }
    
    private func executeCompletionHandlerInMainThread<D: Decodable>(with result: Result<D, MovieError>, completion: @escaping (Result<D, MovieError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
}
