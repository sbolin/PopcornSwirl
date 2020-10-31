//
//  CastDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct CastDTOMapper { // data transfer object
    static func map(dto: CastResponse) -> CastData {
        var director = ""
        var cast: [String] = []
//        let movieID = dto.id
        let movieCast = dto.cast
        let movieCrew = dto.crew
        let movieID = dto.id
        for i in 0..<5 {
            cast.append(movieCast[i].name)
        }
        movieCrew.forEach { (crew) in
            if crew.job == "Director" { director = crew.name }
        }
        return CastData(movieID: movieID, actor: cast, director: director)
    }
}
