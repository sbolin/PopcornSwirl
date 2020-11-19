//
//  CompanyResponse.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/23/20.
//

import Foundation

struct CompanyResponse: Codable {
    var budget: Int
    var id: Int // MovieItem.id
    var imdbId: String
    var releaseDate: Date
    var revenue: Int
    var title: String
    var productionCompanies: [ProductionCompany]
}

struct ProductionCompany: Codable {
    let id: Int
    let logoPath: String?
    let name: String
    let originCountry: String
}
