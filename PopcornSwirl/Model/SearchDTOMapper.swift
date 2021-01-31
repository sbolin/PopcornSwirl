//
//  SearchDTOMapper.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/31/21.
//

import Foundation

/// Mapper Function for creating a collection of movies
struct SearchDTOMapper { // data transfer object
    /// Data Mapping function which maps JSON data (MovieResponse) into MovieDataStore Movie Search data structure
    /// - Parameter dto: pass in the movie response from API call (JSON dat)
    /// - Returns: Array of MovieDataStore MovieSearchItems, which form a MovieDataStore MovieCollection
    static func mapSearch(_ dto: SearchMovieResponse) -> [MovieDataStore.MovieSearchItem] {
        var movieData = [MovieDataStore.MovieSearchItem]()
        for movie in dto.results {
            let movieItem = MovieDataStore.MovieSearchItem(
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                backdropPath: movie.backdropPath,
                releaseDate: movie.releaseDate,
                voteCount: movie.voteCount)
            movieData.append(movieItem)
        }
        return movieData
    }
}
