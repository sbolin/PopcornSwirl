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
    let releaseDate: Date
    let voteAverage: Double
    let voteCount: Int
    let adult: Bool
    let video: Bool
    let popularity: Double
    let posterPath: String
    let backdropPath: String
    // added data
    let bookmarked: Bool = false
    let watched: Bool = false
    let favorite: Bool = false
    
}
