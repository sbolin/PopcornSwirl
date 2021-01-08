//
//  MovieEntity+CoreDataProperties.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/19/20.
//
//

import Foundation
import CoreData


extension MovieEntity {

    @nonobjc public class func movieFetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }
    // main movie data
    @NSManaged public var movieId: Int // Int32
    @NSManaged public var title: String

    // user generated data - bookmark a movie, mark as watched, mark as favorite
    @NSManaged public var bookmarked: Bool
    @NSManaged public var favorite: Bool
    @NSManaged public var watched: Bool
    @NSManaged public var bought: Bool
    @NSManaged public var note: String? // may or may not have note

}
extension MovieEntity : Identifiable {

}
