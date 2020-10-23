//
//  MovieDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/15/20.
//

import Foundation

struct MovieDTOMapper { // data transfer object
  static func map(_ dto: [MovieData]) -> [MovieListData] {  // json data -> model data
    var movieData = [MovieListData]()
    dto.forEach { (result) in
      let movie =  MovieListData(
        id: result.id,
        title: result.title,
        overview: result.overview,
        releaseDate: result.releaseDate,
        voteAverage: result.voteAverage,
        voteCount: result.voteCount,
        adult: result.adult,
        video: result.video,
        popularity: result.popularity,
        posterPath: result.posterPath,
        backdropPath: result.backdropPath
      )
      movieData.append(movie)
    }
    return movieData
  }
}
