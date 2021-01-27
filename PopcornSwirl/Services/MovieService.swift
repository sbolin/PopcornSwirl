//
//  MovieService.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/18/20.
//

import UIKit

/// Services for tMDB.

// create enum of built-in endpoints on tMDB. Note that on nowPlaying is actually used.
enum MovieListEndpoint: String, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    
    case nowPlaying = "now_playing"
    case upcoming
    case topRated = "top_rated"
    case popular
    
    var description: String {
        switch self {
            case .nowPlaying: return "Now Playing"
            case .upcoming: return "Upcoming"
            case .topRated: return "Top Rated"
            case .popular: return "Popular"
        }
    }
}

// error when looking up movies, create human readable errors
enum MovieError: Error, CustomNSError {
    
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case decodeError
    
    var localizedDescription: String {
        switch self {
            case .apiError: return "Failed to fetch data"
            case .invalidEndpoint: return "Invalid Endpoint Entered"
            case .invalidResponse: return "Invalid HTTP Response Received"
            case .noData: return "No Data Received"
            case .decodeError: return "Failed to Decode Data"
        }
    }
    
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}

// error when fetching image
enum ImageLoadingError: Error {
    case invalidResponse
    case networkFailure(Error)
    case invalidData
}
