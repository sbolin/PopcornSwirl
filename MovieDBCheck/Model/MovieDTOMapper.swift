//
//  MovieDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/15/20.
//

import Foundation

struct MovieDTOMapper { // data transfer object
//    static func map(_ dto: MoviesResponse) -> [MovieListData] {  // Original call
    static func map(_ dto: MoviesResponse) -> [MovieController.Movie] {  // call when change to MovieController
//        var movieListData = [MovieListData]() // Original call
        var movieListData = [MovieController.Movie]() // when change to MovieController
//        print("In MovieDTOMapper.map(_ dto: MoviesResponse) -> [MovieController.Movie)")
//        print("number of results \(dto.results.count)")
//        print("dto.results = \(dto.results)")
//        var counter = 0
        for result in dto.results {
  //          let movieData = MovieListData( // Original call
//            print("result:")
//            print("title: \(result.title)")
//            print("id: \(result.id)")
//            print("genreID: \(result.genreIds)")
            let movieData = MovieController.Movie( // when change to MovieController
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
//            print("movieListData.count = \(movieListData.count)")
//            print("movieListData \(movieListData[counter].title)\n")
//            counter += 1

        }
        print("in map, movieListData.count = \(movieListData.count)")
        return movieListData
    }
    
    
    static func map(_ dto: MoviesResponse) -> [MovieListData] {  // Original call
        var movieListData = [MovieListData]() // Original call
        let results = dto.results
        for result in results {
            let movieData = MovieListData( // Original call
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
