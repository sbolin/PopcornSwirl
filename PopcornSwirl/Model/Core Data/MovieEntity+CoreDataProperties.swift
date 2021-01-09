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
    @NSManaged public var movieId: Int32
    @NSManaged public var title: String

    // user generated data - bookmark a movie, mark as watched, mark as favorite
    @NSManaged public var bookmarked: Bool
    @NSManaged public var favorite: Bool
    @NSManaged public var watched: Bool
    @NSManaged public var bought: Bool
    @NSManaged public var note: String? // may or may not have note

}

extension MovieEntity {
    static var bookmarkedMovies: NSFetchRequest<MovieEntity> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.bookmarked), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }
    
    static var watchedMovies: NSFetchRequest<MovieEntity> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.watched), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }
    
    static var favoriteMovies: NSFetchRequest<MovieEntity> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.favorite), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }
    
    static var boughtMovies: NSFetchRequest<MovieEntity> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.bought), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }
}


extension MovieEntity : Identifiable {

}
