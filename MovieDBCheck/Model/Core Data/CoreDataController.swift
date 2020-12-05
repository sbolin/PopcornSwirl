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
                print("Unresolved error \(error), \(error.userInfo)")
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
    
    lazy var bookmarkPredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(Movie.bookmarked), true)
    }()

    lazy var favoritePredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(Movie.favorite), true)
    }()

    lazy var watchedPredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(Movie.watched), true)
    }()
    
    lazy var boughtPredicate: NSPredicate = {
        return NSPredicate(format: "%K = %@", #keyPath(Movie.bought), true)
    }()
    
    lazy var movieResultsController: NSFetchedResultsController<Movie> = {
        let request = Movie.movieFetchRequest()
        let genreSort = NSSortDescriptor(keyPath: \Movie.genre, ascending: true)
        let nameSort = NSSortDescriptor(keyPath: \Movie.title, ascending: true)
        request.sortDescriptors = [genreSort, nameSort]// [todoIDSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedContext,
            sectionNameKeyPath: #keyPath(Movie.collection.genreName),
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    //MARK: - SaveContext
    func saveContext(managedContext: NSManagedObjectContext) {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
}
