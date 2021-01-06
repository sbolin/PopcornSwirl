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
    
    
    /*
    static let shared = CoreDataController() // singleton
    init() {} // Change from private to allow subclassing with new init for unit testing
    
    lazy var modelName = "MovieModel"

    lazy var model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Error creating persistent container: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
 */
    
    lazy var bookmarkPredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(MovieEntity.bookmarked), true)
    }()

    lazy var favoritePredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(MovieEntity.favorite), true)
    }()

    lazy var watchedPredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(MovieEntity.watched), true)
    }()
    
    lazy var boughtPredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(MovieEntity.bought), true)
    }()
    
    lazy var titlePredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(MovieEntity.title), true)
    }()
    
    lazy var idPredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(MovieEntity.movieId), true)
    }()
    
    lazy var movieResultsController: NSFetchedResultsController<MovieEntity> = {
        let request = MovieEntity.movieFetchRequest()
        let nameSort = NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)
        request.sortDescriptors = [nameSort]// [todoIDSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func favoriteTapped(_ movie: MovieDataStore.MovieItem, favoriteStatus: Bool) {
        let movieID = movie.id
    }
    func watchedTapped(_ movie: MovieDataStore.MovieItem, watchedStatus: Bool) {
        
    }
    func bookmarkTapped(_ movie: MovieDataStore.MovieItem, bookmarkStatus: Bool) {
        
    }
    func buyTapped(_ movie: MovieDataStore.MovieItem, buyStatus: Bool) {
        
    }
    func noteAdded(_ movie: MovieDataStore.MovieItem, noteText: String) {
        
    }
    
    //MARK: - SaveContext
    func saveContext(managedContext: NSManagedObjectContext) {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    
    func findMovie(using movieID: Int, in context: NSManagedObjectContext) -> MovieEntity {
        let request = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(MovieEntity.movieId),
                                        movieID)
        
        if let movie = try? context.fetch(request).first {
            return movie
        } else {
            fatalError("Could not find movie from movieID: \(movieID)")
        }
    }
}
