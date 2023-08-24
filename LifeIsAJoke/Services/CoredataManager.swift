//
//  CoredataManager.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 25/08/23.
//

import Foundation
import CoreData

/*
    This is a simple `CoreData` stack that will allow basic generic operations on the persisted store like:
        1. Fetching of all objects of a certain entity.
        2. Clearing all objects of a certain entity.
        3. Inserting new objects for a certain entity.
 
    All of the operations are supposed to happen on background queue. This will be achieved through
    a private queue MOC that will be a child of the main MOC so that the viewContext is able to automatically
    refresh merge changes when they occur on the background context. Main context is only intended to be used when
    the latest set of changes are supposed to be written to the disk
 */

protocol CoreDataManaging {
    var mainMoc: NSManagedObjectContext { get }
    var backgroundMOC: NSManagedObjectContext { get }
    
    func saveChanges() throws
    func commitChanges()
    func fetchEntities<T: NSManagedObject>(ofType t: T.Type,
                                           processingBlock: ((_ fetchRequest: NSFetchRequest<T>) -> Void)?,
                                           completionBlock: @escaping ([T], Error?)->Void)
    func createEntity<T: NSManagedObject>(ofType t: T.Type,
                                          _ processingBlock: @escaping (_ obj: T ) -> Void) throws
    func deleteEntities<T: NSManagedObject>(ofType t: T.Type) throws
}

final class CoreDataManager: CoreDataManaging {
    private let persistentStoreContainer: NSPersistentContainer
    
    var mainMoc: NSManagedObjectContext {
        persistentStoreContainer.viewContext
    }
    
    lazy var backgroundMOC: NSManagedObjectContext = {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = mainMoc
        backgroundContext.automaticallyMergesChangesFromParent = true
        return backgroundContext
    }()
    
    init(modelName: String) {
        persistentStoreContainer = NSPersistentContainer(name: modelName)
        persistentStoreContainer.loadPersistentStores { _, error in
            if error != nil {
                print("Error loading persistent store for \(modelName): \(error!.localizedDescription)")
                // Log the error somewhere for post release monitoring
            } else {
                print("Loaded persistent store")
            }
        }
    }
    
    func saveChanges() throws {
        var error: Error?
        backgroundMOC.performAndWait {
            if backgroundMOC.hasChanges {
                do {
                    try backgroundMOC.save()
                } catch(let e) {
                    error = e
                }
            }
        }
        
        if error != nil {
            throw error!
        }
    }
    
    func commitChanges() {
        mainMoc.performAndWait {
            if mainMoc.hasChanges {
                try? mainMoc.save()
            }
        }
    }
    
    func createEntity<T: NSManagedObject>(ofType t: T.Type,
                                          _ processingBlock: @escaping (_ obj: T ) -> Void) throws {
        var error: Error?
        
        backgroundMOC.performAndWait {
            let entityName = String(describing: t.self)
            let entity: T? = NSEntityDescription.insertNewObject(forEntityName: entityName,
                                                                 into: self.backgroundMOC) as? T
            
            if let entity = entity {
                processingBlock(entity)
            }
            
            do {
                try self.saveChanges()
            } catch(let e) {
                error = e
            }
        }
        
        if error != nil {
            throw error!
        }
    }
    
    func fetchEntities<T: NSManagedObject>(ofType t: T.Type,
                                           processingBlock: ((_ fetchRequest: NSFetchRequest<T>) -> Void)?,
                                           completionBlock: @escaping ([T], Error?)->Void) {
        backgroundMOC.perform {
            let entityName = String(describing: t.self)
            let fetchRequest = NSFetchRequest<T>(entityName: entityName)
            processingBlock?(fetchRequest)
            do {
                let objects = try self.backgroundMOC.fetch(fetchRequest)
                completionBlock(objects, nil)
            }catch (let e) {
                completionBlock([], e)
            }
        }
    }
    
    func deleteEntities<T: NSManagedObject>(ofType t: T.Type) throws {
        var error: Error?
        
        backgroundMOC.performAndWait {
            let entityName = String(describing: t.self)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try backgroundMOC.execute(batchDeleteRequest)
            } catch (let e) {
                error = e
            }
        }
        
        if error != nil {
            throw error!
        }
    }
}
