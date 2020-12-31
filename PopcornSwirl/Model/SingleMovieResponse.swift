//
//  SingleMovieResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/31/20.
//

import Foundation

struct SingleMovieResponse: Decodable, Identifiable, Hashable {
    // Results when fetching by endpoint or genre
    static func == (lhs: SingleMovieResponse, rhs: SingleMovieResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let title: String
    let overview: String
    let genreIds: [Int]
    let backdropPath: String
    let posterPath: String
    let voteAverage: Double
    let voteCount: Int
    
    let popularity: Double
    let adult: Bool
    let video: Bool
    let releaseDate: Date
    
    // Results when fetching specific Movie (by id)
    let runtime: Int
    let genres: [MovieGenre2]
    let credits: MovieCredit2
    let videos: MovieVideoResponse2
    let productionCompanies: [ProductionCompany2]
    
    var cast: [MovieCast2] {
        credits.cast
    }
    
    var crew: [MovieCrew2] {
        credits.crew
    }
    
    var directors: [MovieCrew2] {
        crew.filter { $0.job.lowercased() == "director" }
    }
    
    var producers: [MovieCrew2] {
        crew.filter { $0.job.lowercased() == "producer" }
    }
    
    var screenWriters: [MovieCrew2] {
        crew.filter { $0.job.lowercased() == "story" }
    }
    
    var youtubeTrailers: [MovieVideo2]? {
        videos.results.filter { $0.youtubeURL != nil }
    }
}

struct MovieGenre2: Decodable {
    let name: String
}

struct ProductionCompany2: Decodable {
    let name: String
}

struct MovieCredit2: Decodable {
    let cast: [MovieCast2]
    let crew: [MovieCrew2]
}

struct MovieCast2: Decodable, Identifiable {
    let id: Int
    let character: String
    let name: String
}

struct MovieCrew2: Decodable, Identifiable {
    let id: Int
    let job: String
    let name: String
}

struct MovieVideoResponse2: Decodable {
    let results: [MovieVideo2]
}

struct MovieVideo2: Decodable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    
    var youtubeURL: URL? {
        guard site == "YouTube" else {
            return nil
        }
        return URL(string: "https://youtube.com/watch?v=\(key)")
    }
}


