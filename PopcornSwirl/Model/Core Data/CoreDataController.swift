//
//  CoreDataController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/24/20.
//

import Foundation
import CoreData

class CoreDataController {
    //MARK: - Create CoreData Stack
    
    let persistentContainer: NSPersistentContainer
    var modelName = "MovieModel"
    
    init() {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            } // error
        } // persistentContainer
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    } // init
    
    func favoriteTapped(_ movie: MovieDataStore.MovieItem, favoriteStatus: Bool) {
        let context = persistentContainer.viewContext
        let movieEntity = findMovieByID(using: movie.id, in: context)
        context.perform {
            movieEntity[0].favorite = favoriteStatus
            self.saveContext(object: movieEntity[0], context: context)
        }
        
    }
    func watchedTapped(_ movie: MovieDataStore.MovieItem, watchedStatus: Bool) {
        let context = persistentContainer.viewContext
        let movieEntity = findMovieByID(using: movie.id, in: context)
        context.perform {
            movieEntity[0].watched = watchedStatus
            self.saveContext(object: movieEntity[0], context: context)
        }
    }
    func bookmarkTapped(_ movie: MovieDataStore.MovieItem, bookmarkStatus: Bool) {
        let context = persistentContainer.viewContext
        let movieEntity = findMovieByID(using: movie.id, in: context)
        context.perform {
            movieEntity[0].bookmarked = bookmarkStatus
            self.saveContext(object: movieEntity[0], context: context)
        }
    }
    func buyTapped(_ movie: MovieDataStore.MovieItem, buyStatus: Bool) {
        let context = persistentContainer.viewContext
        let movieEntity = findMovieByID(using: movie.id, in: context)
        context.perform {
            movieEntity[0].bought = buyStatus
            self.saveContext(object: movieEntity[0], context: context)
        }
    }
    func updateNote(_ movie: MovieDataStore.MovieItem, noteText: String) {
        let context = persistentContainer.viewContext
        let movieEntity = findMovieByID(using: movie.id, in: context)
        context.perform {
            movieEntity[0].note = noteText
            self.saveContext(object: movieEntity[0], context: context)
        }
    }
    
    //MARK: - Creeate and Save Movie
    func newMovie(name: String, with movieID: Int) -> MovieEntity {
        let movie = MovieEntity(context: persistentContainer.viewContext)
        movie.title = name
        movie.movieId = Int32(movieID)
        movie.bookmarked = false
        movie.bought = false
        movie.favorite = false
        movie.note = ""
        movie.watched = false
        saveContext(object: movie, context: persistentContainer.viewContext)
        return movie
    }
    
    //MARK: - Delete movie by name
    func deleteMovie(_ movie: MovieEntity) {
        persistentContainer.viewContext.delete(movie)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
    
    //MARK: - SaveContext
    func saveContext(object: NSManagedObject, context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
            context.refresh(object, mergeChanges: true)
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.localizedDescription)")
            context.rollback()
        }
    }
    
    //MARK: Find Movie by Movie ID (used by DetailView
    func findMovieByID(using movieID: Int, in context: NSManagedObjectContext) -> [MovieEntity] {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let movieIDPredicate = NSPredicate(format: "%K == %i", #keyPath(MovieEntity.movieId), Int32(movieID))
        request.predicate = movieIDPredicate
        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Failed to fetch movies: \(error)")
        }
        return []
    }
}
