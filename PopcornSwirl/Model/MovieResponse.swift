//
//  MoviesResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/21/20.
//

import Foundation

struct MovieResponse: Decodable {
    let results: [Movie]
}

struct Movie: Decodable, Identifiable, Hashable { //
    // Results when fetching by endpoint or genre
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: Int
    let title: String
    let overview: String
    let genreIds: [Int]
    let backdropPath: String?
    let posterPath: String?
    let voteAverage: Double
    let voteCount: Int
    
    let popularity: Double
    let adult: Bool
    let video: Bool
    let releaseDate: Date // String in JSON?
}
