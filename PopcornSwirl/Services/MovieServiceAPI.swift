//
//  MovieServiceAPI.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/21/20.
//

import UIKit

//FIXME: MovieServiceAPI
class MovieServiceAPI {
    
    public static let shared = MovieServiceAPI()
    private init() {}
    private let urlSession = URLSession(configuration: .default) // URLSession.shared
    
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
    
    private let jsonDecoder = Utils.jsonDecoder
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    // get movies method given Genre
    public func getMovies<MovieResponse: Decodable>(from genre: Int, page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let url = getMoviesURL(from: genre, for: page)
        urlSession.dataTask(with: url) { result in
            switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                        print("response error")
                        return
                    }
                    do {
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
    
    // get URL for movies from Genre
    //DANGER NOTE! urlComponents is unwrapped, possibly causing crash. Ask Peter about this
    func getMoviesURL(from genre: Int, for page: Int) -> URL {
        var movieURL = baseURL.appendingPathComponent("discover").appendingPathComponent("movie")
        if genre == 99999 {
            movieURL = baseURL.appendingPathComponent("movie").appendingPathComponent("upcoming")
        }
        
        var urlComponents = URLComponents(url: movieURL, resolvingAgainstBaseURL: true)! // <---!!
        
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
        
        var queryItems = [apiQuery, languageQuery, sort, adult, video, page, primaryReleaseDataGTE, primaryReleaseDataLTE, release, voteCount, voteAverage, genreID, origLanguageQuery]
        if genre == 99999 {
            queryItems = [apiQuery]
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url! // <---!!
    }
    
    func getMovieImage(imageURL: URL, completion: @escaping (Bool, UIImage?) -> Void) {
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
                    self.imageCache.setObject(image, forKey: imageKey)
                    completion(true, image)
                }
                else {
                    completion(false, nil)
                }
            }.resume()
        }
    }
    
    func getMovieCast(castURL: URL, completion: @escaping (Bool, CastData?) -> Void) {
        urlSession.dataTask(with: castURL) { (data, response, error) in
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
        }.resume()
    } // getMovieCast
    
    func getMovieCompany(companyURL: URL, completion: @escaping (Bool, CompanyData?) -> Void) {
        //        let session = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: companyURL) { (data, response, error) in
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
}

extension URLSession {
    func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        
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
            DispatchQueue.main.async { // added
                result(.success((response, data)))
            } // added
        }
    }
}

