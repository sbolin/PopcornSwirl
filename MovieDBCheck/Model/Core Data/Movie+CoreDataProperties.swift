//
//  Movie+CoreDataProperties.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/27/20.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func movieFetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }
    // main movie data
    @NSManaged public var id: Int32 //
    @NSManaged public var title: String //
    @NSManaged public var genre: Int32 //
    @NSManaged public var overview: String //
    @NSManaged public var releaseDate: Date //
    @NSManaged public var voteAverage: Double //
    @NSManaged public var voteCount: Int32 //
    @NSManaged public var adult: Bool //
    @NSManaged public var video: Bool //
    @NSManaged public var popularity: Double //
    
    @NSManaged public var posterPath: String? //
    @NSManaged public var posterImage: Data? //
    @NSManaged public var backdropPath: String? //
    @NSManaged public var backdropImage: Data? //
    
    // relationship to Collection Object
    @NSManaged public var collection: Collection //
    
    // user generated data - bookmark a movie, mark as watched, mark as favorite
    @NSManaged public var bookmarked: Bool //
    @NSManaged public var favorite: Bool //
    @NSManaged public var note: String? //
    @NSManaged public var watched: Bool //
    
    // secondary movie data, requires separate fetches for actor/director and company
    @NSManaged public var actor: String //
    @NSManaged public var director: String //
    @NSManaged public var companies: Set<Company> //
    @NSManaged public var actors: Set<Actor> //
}

// MARK: Generated accessors for companies
extension Movie {
    
    @objc(addCompaniesObject:)
    @NSManaged public func addToCompanies(_ value: Company)
    
    @objc(removeCompaniesObject:)
    @NSManaged public func removeFromCompanies(_ value: Company)
    
    @objc(addCompanies:)
    @NSManaged public func addToCompanies(_ values: Set<Company>)
    
    @objc(removeCompanies:)
    @NSManaged public func removeFromCompanies(_ values: Set<Company>)
    
}

// MARK: Generated accessors for actors
extension Movie {
    
    @objc(addActorsObject:)
    @NSManaged public func addToActors(_ value: Actor)
    
    @objc(removeActorsObject:)
    @NSManaged public func removeFromActors(_ value: Actor)
    
    @objc(addActors:)
    @NSManaged public func addToActors(_ values: Set<Actor>)
    
    @objc(removeActors:)
    @NSManaged public func removeFromActors(_ values: Set<Actor>)
    
}

extension Movie : Identifiable {
    
}
