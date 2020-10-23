//
//  MovieDetailData.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct MovieDetailData: Hashable, Identifiable { // Domain model used in App
  
  var id: UUID
  
  // from JSON
   var actor: String     // Cast.CastMember.name
   var director: String  // Crew.CrewMember.name when Crew.CrewMember.job = "Director"
   var company: [String]   // CompanyData.company

  // from MovieListData selection
  var movieData: MovieListData
}
