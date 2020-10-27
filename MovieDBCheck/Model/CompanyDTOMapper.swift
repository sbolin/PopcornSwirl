//
//  CompanyDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct CompanyDTOMapper { // data transfer object
  static func map(_ dto: CompanyResponse) -> CompanyData {
    var companyData = [String]()
    
    let companies = dto.productionCompanies
    for company in companies {
      companyData.append(company.name)
    }
    return CompanyData(company: companyData)
  }
}
