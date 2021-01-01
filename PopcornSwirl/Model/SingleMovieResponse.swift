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
    let backdropPath: String
    let posterPath: String
    let voteAverage: Double
    let voteCount: Int
    
    let popularity: Double
    let adult: Bool
    let video: Bool
    let releaseDate: Date // String in JSON?
    
//     Results when fetching specific Movie (by id)
    let runtime: Int
    let genres: [Genre]
    let credits: Credits
    let videos: Videos
    let productionCompanies: [ProductionCompany]
    
    var cast: [Cast] {
        credits.cast
    }
    
    var crew: [Crew] {
        credits.crew
    }
    
    var directors: [Crew] {
        crew.filter { $0.job.lowercased() == "director" }
    }
    
    var producers: [Crew] {
        crew.filter { $0.job.lowercased() == "producer" }
    }
    
    var screenWriters: [Crew] {
        crew.filter { $0.job.lowercased() == "story" }
    }
    
    var youtubeTrailers: [MovieVideo]? {
        videos.results.filter { $0.youtubeURL != nil }
    }
}

struct Genre: Decodable, Hashable {
    let id: Int
    let name: String
}

struct ProductionCompany: Decodable {
    let name: String
}

struct Credits: Decodable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Decodable, Identifiable {
    let id: Int
    let character: String?
    let name: String
}

struct Crew: Decodable, Identifiable {
    let id: Int
    let job: String
    let name: String
}

struct Videos: Decodable {
    let results: [MovieVideo]
}

struct MovieVideo: Decodable, Identifiable {
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
