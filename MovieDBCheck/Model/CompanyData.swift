//
//  CompanyData.swift
//  MovieDBModel
//
//  Created by Scott Bolin on 10/16/20.
//

import Foundation

struct CompanyData: Hashable, Identifiable { // Domain model used in App
  
  let id = UUID()
  let company: [String]
}
