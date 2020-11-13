//
//  MovieCollection.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/23/20.
//

import Foundation

struct MovieCollection: Hashable {
    let id = UUID()
    let genreID: Int
    let movieData: [MovieListData]
    var genreName: String {
        return genres[genreID]!.rawValue
    }
    
    enum Sections: String, CaseIterable {
        case Action, Adventure, Comedy, Drama, Thriller, Documentary, Mystery, Family, Animation
    }
        
    fileprivate let genres: [Int : Sections] = [
        12:    .Adventure,
        16:    .Animation,
        18:    .Drama,
        28:    .Action,
        35:    .Comedy,
        53:    .Thriller,
        99:    .Documentary,
        9648:  .Mystery,
        10751:  .Family
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
