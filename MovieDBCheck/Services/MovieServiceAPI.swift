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
    private let baseImageURL = URL(string: "https://image.tmdb.org/t/p")!

    
    //Movie parameters
    private let language = "en-US"
    private let origLanguage = "en"
    private let sortBy = "vote_average.desc" // "release_date.desc"
    private let releaseDateGTE = "2019-01-01"
    private let releaseDateLTE = "2020-12-31"
    private let releaseType = 3
    private let voteCountGTE = 1000
    private let voteAverageGTE = 7.0
    private let region = "us"
    
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
    
    public func fetchMovies(from genre: Int, page: Int, group: DispatchGroup, result: @escaping (Result<MoviesResponse, APIServiceError>) -> Void) {

        var url: URL
        let movieURL = baseURL.appendingPathComponent("discover").appendingPathComponent("movie")
        guard var urlComponents = URLComponents(url: movieURL, resolvingAgainstBaseURL: true) else {
            result(.failure(.invalidEndpoint))
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
        let genreID = URLQueryItem(name: "with_genres", value: "\(genre)")
        
        let queryItems = [apiQuery, languageQuery, sort, adult, video, page, primaryReleaseDataGTE, primaryReleaseDataLTE, release, voteCount, voteAverage, genreID, origLanguageQuery]
        urlComponents.queryItems = queryItems
        if urlComponents.url != nil {
            url = urlComponents.url!
        } else {
            return
        }
        if genre == 99999 {
            url = baseURL.appendingPathComponent("movie").appendingPathComponent("upcoming")
        }

        fetchResources(url: url, group: group, completion: result)
    }
    
    // fetch single movie by movie id
    //https://api.themoviedb.org/3/movie/###?api_key=a042fdafc76ac6243a7d5c85b930f1f6&language=en-US
    public func fetchMovie(from movieId: Int, group: DispatchGroup, result: @escaping (Result<MovieData, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieId))
        guard var urlComponents = URLComponents(url: movieURL, resolvingAgainstBaseURL: true) else {
            result(.failure(.invalidEndpoint))
            return
        }
        
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        let languageQuery = URLQueryItem(name: "language", value: language)
        let regionQuery = URLQueryItem(name: "region", value: region)
        let queryItems = [apiQuery, languageQuery, regionQuery]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            result(.failure(.invalidEndpoint))
            return
        }
        fetchResources(url: url, group: group, completion: result)
    }
    
    // new function, replace fetchMovie
    public func getMovie<MovieResponse: Decodable>(with movieID: Int, group: DispatchGroup, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID))
        guard var urlComponents = URLComponents(url: movieURL, resolvingAgainstBaseURL: true) else {
            print("invalid endpoint")
            return
        }
        
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        let languageQuery = URLQueryItem(name: "language", value: language)
        let regionQuery = URLQueryItem(name: "region", value: region)
        let queryItems = [apiQuery, languageQuery, regionQuery]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            print("invalid endpoint")
            return
        }
        group.enter()
        urlSession.dataTask(with: url, group: group) { result in
            defer { group.leave() }
            switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                        print("response error")
                        return
                    }
                    do {
                        print("urlSession success, decode data")
                        let values = try self.jsonDecoder.decode(MovieResponse.self, from: data)
                        completion(.success(values))
                    } catch {
                        print("decode error")
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // not needed - incorporate upcoming into regular fetchMovies function
/*
    public func fetchMovies(from endpoint: Endpoint, group: DispatchGroup, result: @escaping (Result<MoviesResponse, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(endpoint.rawValue)
        fetchResources(url: movieURL, group: group, completion: result)
    }
*/
    // new function to get Cast data
    public func getCast<CastResponse: Decodable>(with url: URL, group: DispatchGroup, completion: @escaping (Result<CastResponse, Error>) -> Void) {
        group.enter()
        urlSession.dataTask(with: url, group: group) { result in
            defer { group.leave() }
            switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                        print("response error")
                        return
                    }
                    do {
                        print("urlSession success, decode data")
                        let values = try self.jsonDecoder.decode(CastResponse.self, from: data)
                        completion(.success(values))
                    } catch {
                        print("decode error")
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
   // new function to get Commpany data
    public func getCompany<CompanyResponse: Decodable>(with url: URL, group: DispatchGroup, completion: @escaping (Result<CompanyResponse, Error>) -> Void) {
        group.enter()
        urlSession.dataTask(with: url, group: group) { result in
            defer { group.leave() }
            switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                        print("response error")
                        return
                    }
                    do {
                        print("urlSession success, decode data")
                        let values = try self.jsonDecoder.decode(CompanyResponse.self, from: data)
                        completion(.success(values))
                    } catch {
                        print("decode error")
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // new image function
    public func getImage(with url: URL, group: DispatchGroup, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        group.enter()
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { group.leave() }
            completionHandler(data, response, error)
        }.resume()
    }


/*
// fetchCast returns CastResponse object -- working
    public func fetchCast(from movieID: Int, result: @escaping (Bool, Error?, CastResponse?) -> Void) {
//       https://api.themoviedb.org/3/movie/###/credits?api_key=a042fdafc76ac6243a7d5c85b930f1f6
        let url = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID)).appendingPathComponent("credits")
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            result(false, nil, nil)
            return
        }
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        urlComponents.queryItems = [apiQuery]
        guard let castURL = urlComponents.url else {
            result(false, nil, nil)
            return
        }
        print("cast url: \(castURL)")

        // uses standard urlsession
        urlSession.dataTask(with: castURL) { data, response, taskerror in
            if let data = data, taskerror == nil {
                if let response = response as? HTTPURLResponse,
                   response.statusCode == 200 {
                    do {
                        let cast = try self.jsonDecoder.decode(CastResponse.self, from: data)
                        result(true, nil, cast)
                    } catch {
                        print("decode error")
                        result(false, nil, nil)
                    }
                } else {
                    print("url response error: \(response.debugDescription)")
                    result(false, nil, nil)
                }
            } else {
                print("task error thrown: \(taskerror.debugDescription)")
                result(false, taskerror, nil)
            }
        }.resume()
    }
    
    // original call, uses fetchResources
    public func fetchCast(movieID: Int, group: DispatchGroup, result: @escaping (Result<CastResponse, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID)).appendingPathComponent("credits")
        // https://api.themoviedb.org/3/movie/###/credits?api_key=a042fdafc76ac6243a7d5c85b930f1f6
        guard var urlComponents = URLComponents(url: movieURL, resolvingAgainstBaseURL: true) else {
            result(.failure(.invalidEndpoint))
            return
        }
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        urlComponents.queryItems = [apiQuery]
        guard let castURL = urlComponents.url else {
            result(.failure(.invalidEndpoint))
            return
        }
        print("fetchCast url: \(castURL)")
        fetchResources(url: castURL, group: group, completion: result)
    }
    
    // original call, uses fetchResouces
    // https://api.themoviedb.org/3/movie/###?api_key=a042fdafc76ac6243a7d5c85b930f1f6
    public func fetchCompany(movieID: Int, group: DispatchGroup, result: @escaping (Result<CompanyResponse, APIServiceError>) -> Void) {
        let movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent(String(movieID))
        guard var urlComponents = URLComponents(url: movieURL, resolvingAgainstBaseURL: true) else {
            result(.failure(.invalidEndpoint))
            return
        }
        let apiQuery = URLQueryItem(name: "api_key", value: apiKey)
        urlComponents.queryItems = [apiQuery]
        guard let companyURL = urlComponents.url else {
            result(.failure(.invalidEndpoint))
            return
        }
        print("fetchCompany url: \(companyURL)")
        fetchResources(url: companyURL, group: group, completion: result)
    }
    
    // original call, fetchImage returns an UIImage object given an image size and imageURL
    public func fetchImage(imageSize: String, imageEndpoint: String, group: DispatchGroup, result: @escaping (Bool, Error?, UIImage?) -> Void) {
        let movieURL = baseImageURL.appendingPathComponent(imageSize).appendingPathComponent(imageEndpoint)
        print("image url: \(movieURL)")
        group.enter()
        urlSession.dataTask(with: movieURL) { data, response, taskerror in
            defer { group.leave() }
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
                print("task error thrown: \(taskerror.debugDescription)")
                result(false, taskerror, nil)
            }
        }.resume()
    }
*/
// revised fetchResouces = url passed in is final url, no need to use urlComponents
    private func fetchResources<T: Decodable>(url: URL, group: DispatchGroup, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        print("fetchResources url: \(url)")
// uses URLSession Extension
////      group.enter()
        urlSession.dataTask(with: url, group: group) { result in
////            defer { group.leave() }
            switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    do {
                        print("urlSession success, decode data")
                        let values = try self.jsonDecoder.decode(T.self, from: data)
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

/*
 // original fetchResources (commented out)
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
    let genreID = URLQueryItem(name: "with_genres", value: "\(genre)")
    
    let queryItems = [apiQuery, languageQuery, sort, adult, video, page, primaryReleaseDataGTE, primaryReleaseDataLTE, release, voteCount, voteAverage, genreID, origLanguageQuery]
    urlComponents.queryItems = queryItems
    guard let url = urlComponents.url else {
        completion(.failure(.invalidEndpoint))
        return
    }
    print("urlSession url: \(url)")
    // uses UELSession Extension
    urlSession.dataTask(with: url) { (result) in
        switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                do {
                    print("urlSession success, decode data")
                    let values = try self.jsonDecoder.decode(T.self, from: data)
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
*/
extension URLSession {
    func dataTask(with url: URL, group: DispatchGroup, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        
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

