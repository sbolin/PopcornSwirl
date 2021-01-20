//
//  MoviesResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/21/20.
//

import Foundation

/// MovieResponse is the datamodel for the JSON data received from the tMDB API
/// Note that results are provided in pages, but for this app only the first page of results is used
struct MovieResponse: Decodable {
    let results: [Movie]
}

/// Movie Data response from API
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
