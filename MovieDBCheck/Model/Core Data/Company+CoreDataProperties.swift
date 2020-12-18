//
//  Company+CoreDataProperties.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/27/20.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func companyFetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var movie: MovieEntity

}

extension Company : Identifiable {

}
