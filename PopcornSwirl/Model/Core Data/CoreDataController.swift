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
    
    static let shared = CoreDataController()
    init() {}
    
    lazy var modelName = "MovieModel"
    lazy var model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    
    func favoriteTapped(_ movie: MovieDataStore.MovieItem, favoriteStatus: Bool) {
        let context = managedContext
        guard let movieEntity = findMovieByID(using: movie.id, in: context) else { return }
        print("favoriteTapped movie: \(movieEntity)")
        context.perform {
            movieEntity.favorite = favoriteStatus
            self.saveContext(object: movieEntity, context: context)
        } // perform
    }
    func watchedTapped(_ movie: MovieDataStore.MovieItem, watchedStatus: Bool) {
        let context = managedContext
        guard let movieEntity = findMovieByID(using: movie.id, in: context) else { return }
        print("watchTapped movie: \(movieEntity)")
        context.perform {
            movieEntity.watched = watchedStatus
            self.saveContext(object: movieEntity, context: context)
        }
    }
    func bookmarkTapped(_ movie: MovieDataStore.MovieItem, bookmarkStatus: Bool) {
        let context = managedContext
        guard let movieEntity = findMovieByID(using: movie.id, in: context) else { return }
        print("bookmarkTapped movie: \(movieEntity)")
        context.perform {
            movieEntity.bookmarked = bookmarkStatus
            self.saveContext(object: movieEntity, context: context)
        }
    }
    func buyTapped(_ movie: MovieDataStore.MovieItem, buyStatus: Bool) {
        let context = managedContext
        guard let movieEntity = findMovieByID(using: movie.id, in: context) else { return }
        print("buyTapped movie: \(movieEntity)")
        context.perform {
            movieEntity.bought = buyStatus
            self.saveContext(object: movieEntity, context: context)
        }
    }
    func updateNote(_ movie: MovieDataStore.MovieItem, noteText: String) {
        let context = managedContext
        guard let movieEntity = findMovieByID(using: movie.id, in: context) else { return }
        print("updateNote: \(movieEntity)")
        context.perform {
            movieEntity.note = noteText
            self.saveContext(object: movieEntity, context: context)
        }
    }
    
    //MARK: - Creeate and Save Movie
    func newMovie(name: String, id: Int) -> MovieEntity {
        let movie = MovieEntity(context: managedContext)
        movie.title = name
        movie.movieId = Int32(id)
        movie.bookmarked = false
        movie.bought = false
        movie.favorite = false
        movie.note = ""
        movie.watched = false
        saveContext(object: movie, context: managedContext)
        return movie
    }
    
    //MARK: - Delete movie by name
    func deleteMovie(_ movie: MovieEntity) {
        managedContext.delete(movie)
        do {
            try managedContext.save()
        } catch {
            managedContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
    
    //MARK: - SaveContext
    func saveContext(object: NSManagedObject, context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
            context.refresh(object, mergeChanges: true)
            print("Movie saved")
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.localizedDescription)")
            context.rollback()
        }
    }
    
    //MARK: Find Movie by Movie ID (used by DetailView
    func findMovieByID(using id: Int, in context: NSManagedObjectContext) -> MovieEntity? {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let movieIdPredicate = NSPredicate(format: "%K = %i", #keyPath(MovieEntity.movieId), Int32(id))
        request.predicate = movieIdPredicate
        do {
            print("find movie \(id)")
            let movies = try context.fetch(request)
            for movie in movies {
                if movie.movieId == id {
                    return movie
                } // if
            } // for in
        } catch {
            print("Failed to fetch movies: \(error)")
        }
        return nil
    }
    
    //MARK: Method to check if entity exists
    func entityExists(using id: Int, in context: NSManagedObjectContext) -> Bool {
        let idRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        let movieRequest: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        idRequest.includesSubentities = false
        var entitiesCount = 0
        var movieIdExists = false
        do {
            entitiesCount = try context.count(for: idRequest)
            let movies = try context.fetch(movieRequest)
            print("entityExists movie count: \(movies.count)")
            for movie in movies {
                if movie.movieId == id {
                    movieIdExists = true
                    print("Movie \(id) exists")
                    break
                }
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return (entitiesCount > 0 && movieIdExists)
    }
    
}
