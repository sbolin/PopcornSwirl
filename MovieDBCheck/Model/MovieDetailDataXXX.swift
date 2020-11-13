//
//  MovieDetailData.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct MovieDetailData: Hashable {
    
    // from MovieListData selection
    var movieData: MovieListData
    
    // from JSON
    var actor: String     // Cast.CastMember.name
    var director: String  // Crew.CrewMember.name when Crew.CrewMember.job = "Director"
    var company: [String]   // CompanyData.company

}
