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
    private init() {}
    
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
    
    lazy var bookmarkedMovies: NSFetchRequest<MovieEntity> = {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.bookmarked), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }()
    
    lazy var watchedMovies: NSFetchRequest<MovieEntity> = {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.watched), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }()
    
    lazy var favoriteMovies: NSFetchRequest<MovieEntity> = {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.favorite), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }()
    
    lazy var boughtMovies: NSFetchRequest<MovieEntity> = {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.movieFetchRequest()
        let sort = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        let predicate = NSPredicate(format: "%K == %d", #keyPath(MovieEntity.bought), true)
        request.sortDescriptors = sort
        request.predicate = predicate
        return request
    }()
    
    
    func favoriteTapped(_ movie: MovieDataStore.MovieItem, favoriteStatus: Bool) {
        guard let movieEntity = findMovieByID(using: movie.id, in: managedContext) else { return }
        managedContext.perform {
            movieEntity.favorite = favoriteStatus
            self.saveContext(object: movieEntity, context: self.managedContext)
        } // perform
    }
    func watchedTapped(_ movie: MovieDataStore.MovieItem, watchedStatus: Bool) {
        guard let movieEntity = findMovieByID(using: movie.id, in: managedContext) else { return }
        managedContext.perform {
            movieEntity.watched = watchedStatus
            self.saveContext(object: movieEntity, context: self.managedContext)
        }
    }
    func bookmarkTapped(_ movie: MovieDataStore.MovieItem, bookmarkStatus: Bool) {
        guard let movieEntity = findMovieByID(using: movie.id, in: managedContext) else { return }
        managedContext.perform {
            movieEntity.bookmarked = bookmarkStatus
            self.saveContext(object: movieEntity, context: self.managedContext)
        }
    }
    func buyTapped(_ movie: MovieDataStore.MovieItem, buyStatus: Bool) {
        guard let movieEntity = findMovieByID(using: movie.id, in: managedContext) else { return }
        managedContext.perform {
            movieEntity.bought = buyStatus
            self.saveContext(object: movieEntity, context: self.managedContext)
        }
    }
    func updateNote(_ movie: MovieDataStore.MovieItem, noteText: String) {
        guard let movieEntity = findMovieByID(using: movie.id, in: managedContext) else { return }
        managedContext.perform {
            movieEntity.note = noteText
            self.saveContext(object: movieEntity, context: self.managedContext)
        }
    }
    
    //MARK: - Creeate and Save Movie
    func createMovie(name: String, id: Int) -> MovieEntity {
        let movie = MovieEntity(context: managedContext)
        movie.title = name
        movie.movieId = Int32(id)
        movie.bookmarked = false
        movie.bought = false
        movie.favorite = false
        movie.note = ""
        movie.watched = false
        saveContext(object: movie, context: managedContext)
        print("CoreDataController.createMovie \(name), \(id) success")
        return movie
    }
    
    //MARK: - Delete movie by name
    func deleteMovie(_ movie: MovieEntity) {
        managedContext.delete(movie)
        do {
            try managedContext.save()
            print("CoreDataController.deleteMovie \(movie.title)")
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
            let movies = try context.fetch(request)
            for movie in movies {
                if movie.movieId == id {
                    print("CoreDataController.findMovieByID success: \(id)")
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
            for movie in movies {
                if movie.movieId == id {
                    movieIdExists = true
                    break
                }
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return (entitiesCount > 0 && movieIdExists)
    }
    
    //MARK: Method to fetch requested movies and return []
    
    func getMovieIDs(request: NSFetchRequest<MovieEntity>) -> [Int32] {
        var id = [Int32]()
        let fetchedMovies = try! managedContext.fetch(request)
        for movie in fetchedMovies {
            id.append(movie.movieId)
        }
        return id
    }
}

