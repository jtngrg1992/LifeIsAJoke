//
//  JokePersistentWorker.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 25/08/23.
//

import Foundation

/*
    A simple class that utilizes generic `CoreDataManager` to execute various disk based operations
    on Jokes.
    This will:
        1. Save the jokes array into CoreData persistent store.
        2. Retreive persisted jokes from the persistent store.
        3. Clear all persisted jokes on the disk.
 */

protocol JokesPersistentWorking {
    func getPersistedJokes() async throws -> [String]
    func saveJokes(_ jokes: [String]) throws
    func clearSavedJokes() throws
    func writeChanges()
}

final class JokesPersistentWorker: JokesPersistentWorking {
    private let coreDataManager: CoreDataManaging
    
    init(coreDataManager: CoreDataManaging) {
        self.coreDataManager = coreDataManager
    }
    
    func getPersistedJokes() async throws -> [String] {
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<[String], Error>) in
            coreDataManager.fetchEntities(ofType: CDJoke.self, processingBlock: { fetchRequest in
                fetchRequest.fetchLimit = 10
            }, completionBlock: { persistedJokes, error in
                if error != nil {
                    continuation.resume(throwing: error!)
                } else {
                    let mappedJokes = persistedJokes.compactMap { $0.content }
                    continuation.resume(returning: mappedJokes)
                }
            })
        })
    }
    
    func saveJokes(_ jokes: [String]) throws {
        for i in 0..<jokes.count {
            try coreDataManager.createEntity(ofType: CDJoke.self) { obj in
                obj.content = jokes[i]
            }
        }
    }
    
    func clearSavedJokes() throws {
        try coreDataManager.deleteEntities(ofType: CDJoke.self)
    }
    
    func writeChanges() {
        coreDataManager.commitChanges()
    }
}
