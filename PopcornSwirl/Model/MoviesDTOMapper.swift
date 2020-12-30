//
//  MoviesDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/15/20.
//

import Foundation

struct MoviesDTOMapper { // data transfer object
    static func map(_ dto: MovieResponse) -> [MovieDataStore.MovieItem] {  // call when change to MovieController
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
