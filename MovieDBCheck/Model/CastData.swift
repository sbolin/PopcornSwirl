//
//  CastData.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct CastData: Hashable, Identifiable { // Domain model used in App
    
    var id = UUID()
    var movieID: Int

    var actor: [String]     // CastResponse.[CastMember].name
    var director: String  // CastResponse.[CrewMember].name when Crew.CrewMember.job = "Director"
}
