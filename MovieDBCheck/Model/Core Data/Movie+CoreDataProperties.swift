//
//  Movie+CoreDataProperties.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/24/20.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func movieFetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var id: Int16
    @NSManaged public var title: String
    @NSManaged public var overview: String
    @NSManaged public var releaseDate: Date
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int16
    @NSManaged public var adult: Bool
    @NSManaged public var video: Bool
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var bookmarked: Bool
    @NSManaged public var watched: Bool
    @NSManaged public var favorite: Bool
    @NSManaged public var actor: String
    @NSManaged public var director: String
    @NSManaged public var collection: Collection
    @NSManaged public var companies: Set<Company>

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

extension Movie : Identifiable {

}
