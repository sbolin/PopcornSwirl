//
//  MovieResp.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/18/20.
//

import Foundation

struct MovieResp: Decodable {
    let movies: [Movie]
    
    private enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}

struct Movie: Decodable, Identifiable, Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let title: String
    let backdropPath: String
    let posterPath: String
    let overview: String
    let voteAverage: Double
    let voteCount: Int
    
    let popularity: Double
    let adult: Bool
    let video: Bool
    
    let runtime: Int
    let releaseDate: Date
    
    let genres: [MovieGenre]?
    let credits: MovieCredit?
    let videos: MovieVideoResponse?
    let productionCompanies: [ProductionCompany]
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath )")!
    }
    
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w780\(posterPath )")!
    }
    
    var genreText: String {
        genres?.first?.name ?? "n/a"
    }
    
    var ratingText: String {
        let rating = Int(voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        return ratingText
    }
    
    var scoreText: String {
        guard ratingText.count > 0 else {
            return "n/a"
        }
        return "\(ratingText.count)/10"
    }
    
    var yearText: String {
        return Utils.yearFormatter.string(from: releaseDate)
    }
    
    var formattedDate: String {
        return Utils.dateFormatter.string(from: releaseDate)
    }
    
    var durationText: String {
        if runtime == 0 {
            return "n/a"
        } else {
            return Utils.durationFormatter.string(from: TimeInterval(runtime) * 60) ?? "n/a"
        }
    }
    
    var cast: [Cast]? {
        credits?.cast
    }
    
    var crew: [Crew]? {
        credits?.crew
    }
    
    var directors: [Crew]? {
        crew?.filter { $0.job.lowercased() == "director" }
    }
    
    var producers: [Crew]? {
        crew?.filter { $0.job.lowercased() == "producer" }
    }
    
    var screenWriters: [Crew]? {
        crew?.filter { $0.job.lowercased() == "story" }
    }
    
    var youtubeTrailers: [MovieVideo]? {
        videos?.results.filter { $0.youtubeURL != nil }
    }
}

struct MovieGenre: Decodable {
    let name: String
}

struct ProductionCompany: Decodable {
    let name: String
}

struct MovieCredit: Decodable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Decodable, Identifiable {
    let id: Int
    let character: String
    let name: String
}

struct Crew: Decodable, Identifiable {
    let id: Int
    let job: String
    let name: String
}

struct MovieVideoResponse: Decodable {
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

