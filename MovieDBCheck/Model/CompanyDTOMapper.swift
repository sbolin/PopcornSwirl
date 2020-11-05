//
//  CompanyDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct CompanyDTOMapper { // data transfer object
  static func map(dto: CompanyResponse) -> CompanyData {
    var companies = [String]()
    
    let productionCompanies = dto.productionCompanies
    for company in productionCompanies {
        companies.append(company.name)
    }
    return CompanyData(movieID: dto.id, company: companies)
  }
}
