//
//  SearchMovieResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/31/21.
//

import Foundation

/// MovieResponse is the datamodel for the JSON data received from the tMDB API
/// Note that results are provided in pages, but for this app only the first page of results is used
struct SearchMovieResponse: Decodable {
    let results: [SearchMovie]
}

/// Movie Data response from API
struct SearchMovie: Decodable, Identifiable, Hashable { //
    // Results when fetching by endpoint or genre
    static func == (lhs: SearchMovie, rhs: SearchMovie) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let title: String
    let overview: String
    let backdropPath: String?
    let voteCount: Int
    
    let releaseDate: Date // String in JSON?
}
