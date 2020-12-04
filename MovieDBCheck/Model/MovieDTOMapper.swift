//
//  MovieDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/15/20.
//

import Foundation

struct MovieDTOMapper { // data transfer object
    static func map(_ dto: MoviesResponse) -> [MovieDataController.MovieItem] {  // call when change to MovieController
        var movieData = [MovieDataController.MovieItem]()
        for result in dto.results {
            let movie = MovieDataController.MovieItem(
                id: result.id,
                title: result.title,
                overview: result.overview,
                genreID: result.genreIds,
                releaseDate: result.releaseDate,
                voteAverage: result.voteAverage,
                voteCount: result.voteCount,
                adult: result.adult,
                video: result.video,
                popularity: result.popularity,
                posterPath: result.posterPath,
                backdropPath: result.backdropPath)
            movieData.append(movie)

        }
        return movieData
    }
}
