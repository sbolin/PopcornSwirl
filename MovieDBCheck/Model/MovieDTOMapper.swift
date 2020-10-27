//
//  MovieDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/15/20.
//

import Foundation

struct MovieDTOMapper { // data transfer object
    static func map(_ dto: MoviesResponse) -> [MovieListData] {  // json data -> model data
        var movieListData = [MovieListData]()
        let results = dto.results
        for result in results {
            let movieData = MovieListData(
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
            movieListData.append(movieData)
        }
        return movieListData
    }
    
    static func map(_ dto: MovieData) -> [MovieListData] {  // json data -> model data
        var movieListData = [MovieListData]()
            let movieData = MovieListData(
                id: dto.id,
                title: dto.title,
                overview: dto.overview,
                genreID: dto.genreIds,
                releaseDate: dto.releaseDate,
                voteAverage: dto.voteAverage,
                voteCount: dto.voteCount,
                adult: dto.adult,
                video: dto.video,
                popularity: dto.popularity,
                posterPath: dto.posterPath,
                backdropPath: dto.backdropPath)
            movieListData.append(movieData)

        return movieListData
    }
}
