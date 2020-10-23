//
//  CompanyDTOMapper.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct CompanyDTOMapper { // data transfer object
  static func map(_ dto: [ProductionCompany]) -> CompanyData {
    var companyData = [String]()
    
    dto.forEach { (result) in
      companyData.append(result.name)
    }
    return CompanyData(company: companyData)
  }
}
