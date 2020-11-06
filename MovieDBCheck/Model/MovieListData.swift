//
//  MovieListData.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/23/20.
//

import Foundation

struct MovieListData: Hashable, Identifiable { // Domain model used in App
    
    let id: Int
    let title: String
    let overview: String
    let genreID: [Int]
    let releaseDate: Date
    let voteAverage: Double
    let voteCount: Int
    let adult: Bool
    let video: Bool
    let popularity: Double
    let posterPath: String
    let backdropPath: String
    
    // actor data
    let actor: [String] = []
    let director: String = ""
    
    // company data
    let company: [String] = []
    
    // user added data
    let bookmarked: Bool = false
    let watched: Bool = false
    let favorite: Bool = false
    let note: String = ""
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ***NOTE: THIS IS NOT USED, CHANGED TO MovieController***
