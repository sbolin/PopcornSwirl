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
    @NSManaged public var id: Int32
    @NSManaged public var title: String
    @NSManaged public var genre: String
    @NSManaged public var overview: String
    @NSManaged public var releaseDate: Date
    @NSManaged public var runtime: String
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int32
    @NSManaged public var adult: Bool
    @NSManaged public var video: Bool
    @NSManaged public var popularity: Double
    
    // path to images
    @NSManaged public var backdropPath: String?
    @NSManaged public var posterPath: String?
    
    // derived stored image data
    @NSManaged public var backdropImage: Data?
    @NSManaged public var posterImage: Data?
    
    
    // user generated data - bookmark a movie, mark as watched, mark as favorite
    @NSManaged public var bookmarked: Bool
    @NSManaged public var favorite: Bool
    @NSManaged public var watched: Bool
    @NSManaged public var bought: Bool
    @NSManaged public var note: String? // may or may not have note
    
    // secondary movie data
    @NSManaged public var actor: String
    @NSManaged public var director: String

}

extension MovieEntity : Identifiable {

}
