//
//  MoviesResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/21/20.
//

import Foundation

struct MovieResponse: Decodable {
    let movies: [MovieData]
    
    private enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}

struct MovieData: Decodable, Identifiable, Hashable {
    static func == (lhs: MovieData, rhs: MovieData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
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
