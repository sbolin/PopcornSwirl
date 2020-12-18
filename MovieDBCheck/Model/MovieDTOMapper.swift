//
//  MovieDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/15/20.
//

import Foundation

struct MovieDTOMapper { // data transfer object
    static func map(_ dto: MovieResponse) -> [MovieDataController.MovieItem] {  // call when change to MovieController
        var movieData = [MovieDataController.MovieItem]()
        for movie in dto.movies {
            let movieItem = MovieDataController.MovieItem(
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                genreID: movie.genreIds,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                voteCount: movie.voteCount,
                adult: movie.adult,
                video: movie.video,
                popularity: movie.popularity,
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath)
            movieData.append(movieItem)

        }
        return movieData
    }
}
