//
//  Actor+CoreDataProperties.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/27/20.
//
//

import Foundation
import CoreData


extension Actor {

    @nonobjc public class func actorFetchRequest() -> NSFetchRequest<Actor> {
        return NSFetchRequest<Actor>(entityName: "Actor")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var movie: MovieEntity

}

extension Actor : Identifiable {

}
