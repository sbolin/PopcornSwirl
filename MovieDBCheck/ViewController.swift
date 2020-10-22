//
//  ViewController.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/21/20.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call movieserviceapi to get movies from given genre response
        let genre = 28
        let page = 1
        MovieServiceAPI.shared.fetchMovies(from: genre, page: page) { (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let movieResponse):
                    print("Genre #\(genre):")
                    for (num, movie) in movieResponse.results.enumerated() {
                        print("MovieData \(num):")
                        print("Title: \(movie.title)")
                        print("id: \(movie.id)")
                        print("Overview: \(movie.overview)")
                        print("Release date: \(movie.releaseDate)")
                        print("Vote Average: \(movie.voteAverage)")
                        print("Vote Count: \(movie.voteCount)")
                        print("\n")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
        
        // call movieserviceapi to get single movie response
        MovieServiceAPI.shared.fetchMovie(movieId: 550) { (result: Result<MovieData, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let movie):
                    print("MovieData: 550")
                    print("Title: \(movie.title)")
                    print("id: \(movie.id)")
                    print("Overview: \(movie.overview)")
                    print("Release date: \(movie.releaseDate)")
                    print("Vote Average: \(movie.voteAverage)")
                    print("Vote Count: \(movie.voteCount)")
                    print("\n")
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
        MovieServiceAPI.shared.fetchCast(movieID: 550) { (result: Result<CastResponse, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let response):
                    print("Cast and Crew for movie: \(response.id)")
                    print("Cast:")
                    for cast in response.cast {
                        print("Character: \(cast.character)")
                        print("id: \(cast.id)")
                        print("Actor: \(cast.name)")
                        print("\n")
                    }
                    print("Crew:")
                    for crew in response.crew {
                        print("Crew for movie 550")
                        print("Position: \(crew.job)")
                        print("id: \(crew.id)")
                        print("Name: \(crew.name)")
                        print("\n")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
        MovieServiceAPI.shared.fetchCompany(movieID: 550) { (result: Result<CompanyResponse, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let response):
                    print("Companies for movie: \(response.id)")
                    for company in response.productionCompanies {
                        print("Company: \(company.name)")
                        print("Company ID: \(company.id)")
                        print("Country: \(company.originCountry)")
                        print("\n")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
 /*
        // call movieserviceapi to get movies from endpoint
        let endpoints = MovieServiceAPI.Endpoint.allCases
        endpoints.forEach { (endPoint) in
            MovieServiceAPI.shared.fetchMovies(from: endPoint) { (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
                switch result {
                    case .success(let movieResponse):
                        print("\(endPoint):")
                        for (num, movie) in movieResponse.results.enumerated() {
                            print("MovieData \(num):")
                            print("Title: \(movie.title)")
                            print("id: \(movie.id)")
                            print("Overview: \(movie.overview)")
                            print("Release date: \(movie.releaseDate)")
                            print("Vote Average: \(movie.voteAverage)")
                            print("Vote Count: \(movie.voteCount)")
                            print("\n")
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
        */
    }
}

