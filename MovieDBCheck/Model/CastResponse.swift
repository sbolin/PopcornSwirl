//
//  CastResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/23/20.
//

import Foundation

struct CastResponse: Codable {
    let id: Int // Movie.id, 550 in call
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Codable {
    let castId: Int
    let character: String
    let creditId: String
    let gender: Int
    let id: Int
    let name: String
    let order: Int
    let profilePath: String?
}

struct CrewMember: Codable {
    let creditId: String
    let department: Department
    let gender: Int
    let id: Int
    let job: String
    let name: String
    let profilePath: String?
}

enum Department: String, Codable {
    case art = "Art"
    case camera = "Camera"
    case costumeMakeUp = "Costume & Make-Up"
    case crew = "Crew"
    case directing = "Directing"
    case editing = "Editing"
    case lighting = "Lighting"
    case production = "Production"
    case sound = "Sound"
    case visualEffects = "Visual Effects"
    case writing = "Writing"
}
    
