//
//  MoviesDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/15/20.
//

import Foundation

/// Mapper Function for creating a collection of movies
struct MoviesDTOMapper { // data transfer object
    /// Data Mapping Function which maps JSON data (MovieReponse) into MovieDataStore Movie item
    /// - Parameter dto: pass in the movie response from API call (JSON dat)
    /// - Returns: Array of MovieDataStore Movie Items, which form a MovieDataStore MovieCollection
    static func map(_ dto: MovieResponse) -> [MovieDataStore.MovieItem] {
        var movieData = [MovieDataStore.MovieItem]()
        for movie in dto.results {
            let movieItem = MovieDataStore.MovieItem(
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath,
                genreIds: movie.genreIds,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                voteCount: movie.voteCount,
                popularity: movie.popularity,
                adult: movie.adult,
                video: movie.video)
            movieData.append(movieItem)
        }
        return movieData
    }
}
