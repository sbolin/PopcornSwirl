//
//  Collection+CoreDataProperties.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/27/20.
//
//

import Foundation
import CoreData


extension Collection {

    @nonobjc public class func collectionFetchRequest() -> NSFetchRequest<Collection> {
        return NSFetchRequest<Collection>(entityName: "Collection")
    }

    @NSManaged public var genreID: Int32
    @NSManaged public var genreName: String
    @NSManaged public var id: UUID
    @NSManaged public var movies: Set<Movie>

}

// MARK: Generated accessors for movies
extension Collection {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: Movie)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: Movie)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: Set<Movie>)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: Set<Movie>)

}

extension Collection : Identifiable {

}
