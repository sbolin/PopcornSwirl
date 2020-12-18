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
    @NSManaged public var id: Int16
    @NSManaged public var title: String
    @NSManaged public var genre: Int16
    @NSManaged public var overview: String
    @NSManaged public var releaseDate: Date
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int16
    @NSManaged public var adult: Bool
    @NSManaged public var video: Bool
    @NSManaged public var popularity: Double
    
    // path to images
    @NSManaged public var backdropPath: String?
    @NSManaged public var posterPath: String?
    
    // derived stored image data
    @NSManaged public var backdropImage: Data?
    @NSManaged public var posterImage: Data?

    // relationship to Collection Object
    @NSManaged public var collection: Collection

    // user generated data - bookmark a movie, mark as watched, mark as favorite
    @NSManaged public var bookmarked: Bool
    @NSManaged public var favorite: Bool
    @NSManaged public var watched: Bool
    @NSManaged public var bought: Bool
    @NSManaged public var note: String? // may or may not have note
    
    // secondary movie data
    @NSManaged public var actor: String
    @NSManaged public var director: String
    @NSManaged public var companies: Set<Company>
    @NSManaged public var actors: Set<Actor>

}

// MARK: Generated accessors for actors
extension MovieEntity {

    @objc(addActorsObject:)
    @NSManaged public func addToActors(_ value: Actor)

    @objc(removeActorsObject:)
    @NSManaged public func removeFromActors(_ value: Actor)

    @objc(addActors:)
    @NSManaged public func addToActors(_ values: Set<Actor>)

    @objc(removeActors:)
    @NSManaged public func removeFromActors(_ values: Set<Actor>)

}

// MARK: Generated accessors for companies
extension MovieEntity {

    @objc(addCompaniesObject:)
    @NSManaged public func addToCompanies(_ value: Company)

    @objc(removeCompaniesObject:)
    @NSManaged public func removeFromCompanies(_ value: Company)

    @objc(addCompanies:)
    @NSManaged public func addToCompanies(_ values: Set<Company>)

    @objc(removeCompanies:)
    @NSManaged public func removeFromCompanies(_ values: Set<Company>)

}

extension MovieEntity : Identifiable {

}
