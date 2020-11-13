//
//  MoviesResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/21/20.
//

import Foundation

struct MoviesResponse: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [MovieData]
}
struct MovieData: Codable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: Date
    let voteAverage: Double
    let voteCount: Int
    let adult: Bool
    let video: Bool
    let popularity: Double
    let posterPath: String
    let backdropPath: String
    let genreIds: [Int]
}
