//
//  CastData.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct CastData: Hashable, Identifiable { // Domain model used in App
    
    let id = UUID()
    let movieID: Int      // CastResponse.id
    let actor: String     // CastResponse.[CastMember].name
    let director: String  // CastResponse.[CrewMember].name when Crew.CrewMember.job = "Director"
}
