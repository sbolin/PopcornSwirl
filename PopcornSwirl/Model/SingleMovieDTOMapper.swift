//
//  SingleMovieDTOMapper.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/31/20.
//

import Foundation

struct SingleMovieDTOMapper { // data transfer object

    
    static func map(_ dto: SingleMovieResponse) -> MovieDataStore.MovieItem {
        var movieGenres: [String] = []
        var movieCast: [String] = []
        var directors: [String] = []
        var companies: [String] = []
        for genre in dto.genres {
            movieGenres.append(genre.name)
        }
        for cast in dto.cast {
            movieCast.append(cast.name)
        }
        for director in dto.directors {
            directors.append(director.name)
        }
        
        for company in dto.productionCompanies {
            companies.append(company.name)
        }
        
        let movieItem = MovieDataStore.MovieItem(
            uuid: UUID(),
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            genreIds: dto.genreIds,
            releaseDate: dto.releaseDate,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            popularity: dto.popularity,
            adult: dto.adult,
            video: dto.video,
//            backdropImage: UIImage(),
//            posterImage: UIImage(),
            runtime: dto.runtime,
            genres: movieGenres,
            actor: movieCast,
            director: directors,
            company: companies)
//            bookmarked: false,
//            watched: false,
//            favorite: false,
//            note: "")
        return movieItem
    }
}
