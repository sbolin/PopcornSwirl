//
//  Company+CoreDataProperties.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/24/20.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func companyFetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var movie: Movie

}

extension Company : Identifiable {

}
