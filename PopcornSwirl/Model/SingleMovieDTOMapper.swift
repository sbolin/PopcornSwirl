//
//  SingleMovieDTOMapper.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/31/20.
//

import Foundation

struct SingleMovieDTOMapper { // data transfer object
    static func map(_ dto: MovieResponse) -> [MovieDataStore.MovieItem] {  // call when change to MovieController
        var movieData = [MovieDataStore.MovieItem]()
        for movie in dto.results {
            let movieItem = MovieDataStore.MovieItem(
                uuid: UUID(),
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
                video: movie.video,
//                backdropImage: UIImage(),
//                posterImage: UIImage(),
                runtime: movie.runtime,
                genres: movie.genres,
                actor: movie.cast,
                director: movie.directors,
                company: movie.productionCompanies,
                bookmarked: false,
                watched: false,
                favorite: false,
                note: "")
            movieData.append(movieItem)
        }
        return movieData
    }
}
