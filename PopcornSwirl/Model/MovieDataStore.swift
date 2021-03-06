//
//  MovieDataStore.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/28/20.
//

import UIKit


/// Main movie data store, consists of MovieCollection and MovieItem. MovieCollection holds MovieItem objects for given Genre
class MovieDataStore {
    /// overarching collection type
    struct MovieCollection: Hashable, Identifiable {
        let id = UUID()
        let genreID: Int
        var movies: [MovieItem]
        
        enum Genres: Int, Hashable, CaseIterable, Identifiable {
            var id: Int { rawValue }
            
            case Popular = 99999
            case Action    = 28
            case Adventure = 12
            case Animation = 16
            case Comedy    = 35
            case Drama     = 18
            case Family    = 10751
            case Mystery   = 9648
            case Thriller  = 53
            case Upcoming  = 99998
            
            
            var description: String {
                switch self {
                    case .Popular: return "Popular"
                    case .Action: return "Action"
                    case .Adventure: return "Adventure"
                    case .Animation: return "Animation"
                    case .Comedy: return "Comedy"
                    case .Drama: return "Drama"
                    case .Family: return "Family"
                    case .Mystery: return "Mystery"
                    case .Thriller: return "Thriller"
                    case .Upcoming: return "Upcoming"
                }
            }
        }
    }
    
    /// Struct holding individual movie data. [MovieItem] makes up a MovieCollection
    struct MovieItem: Hashable, Identifiable {
        
        static func == (lhs: MovieItem, rhs: MovieItem) -> Bool {
            lhs.uuid == rhs.uuid //uuid
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid) // uuid
        }
        
        // Domain model used in App
        var uuid = UUID() // use this so that DiffableDataSource will display same movie more than once (when a movie is part of more than one genre)
        var id: Int
        var title: String
        var overview: String
        var posterPath: String?
        var backdropPath: String?
        var genreIds: [Int]
        var releaseDate: Date
        var voteAverage: Double
        var voteCount: Int
        var popularity: Double
        var adult: Bool
        var video: Bool
        
        // data from domain model
        var backdropURL: URL {
            return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath ?? "")")!
        }
        var backdropImage = UIImage() // using backdropURL
        
        var posterURL: URL {
            return URL(string: "https://image.tmdb.org/t/p/w780\(posterPath ?? "")")!
        }
        var posterImage = UIImage() // using posterURL
        
        // data from fetching specific movie (by id)
        var runtime: Int?
        var genres: [String]?
        
        // actor data
        var actor: [String] = []
        var director: [String] = []
        
        // company data
        var company: [String] = []
        
        // user added data
        var bookmarked: Bool = false
        var watched: Bool = false
        var favorite: Bool = false
        var bought: Bool = false
        var note: String = ""
        
        var genreText: String {
            genres?.first ?? "n/a"
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
            guard let runtime = self.runtime, runtime > 0 else {
                return "n/a"
            }
            return Utils.durationFormatter.string(from: TimeInterval(runtime) * 60) ?? "n/a"
        }
    }
    
    /// Struct holding individual movie data. [MovieSearchItem] makes up a MovieCollection
    struct MovieSearchItem: Hashable, Identifiable {
        
        static func == (lhs: MovieSearchItem, rhs: MovieSearchItem) -> Bool {
            lhs.id == rhs.id //uuid
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id) // uuid
        }
        
        // Domain model used in App
        var id: Int
        var title: String
        var overview: String
        var backdropPath: String?
        var releaseDate: Date
        var voteCount: Int


        
        var backdropURL: URL {
            return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath ?? "")")!
        }
    }
}
