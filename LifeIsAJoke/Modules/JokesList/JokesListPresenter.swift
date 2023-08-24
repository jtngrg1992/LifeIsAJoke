//
//  JokesListPresenter.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import Foundation


protocol JokesListView: NSObject {
    var presenter: JokesListPresentable { get }
    
    func display(aJoke joke: String, atIndex index: Int, whileReplacingOldJoke: Bool)
    func refreshVisibleRows()
    func refreshJokesList()
}

final class JokesListPresenter {
    weak var view: JokesListView?
    var jokeCount: Int {
        jokes.length
    }
    
    private let jokes: JokeList<String>
    private var periodicJokeWorker: PeriodicJokeWorking
    private let jokesPersistor: JokesPersistentWorking
    
    init(periodicJokeWorker: PeriodicJokeWorking,
         maxJokeCount: Int,
         jokesPersistor: JokesPersistentWorking) {
        self.periodicJokeWorker = periodicJokeWorker
        self.jokes = JokeList<String>(maxJokeCount)
        self.jokesPersistor = jokesPersistor
        
    }
    
    func getJoke(atIndex index: Int) -> String {
        if let joke = jokes.getJoke(atIndex: index) {
            return joke
        }
        fatalError("un expected index(\(index) passed while fetching a joke")
    }
    
    deinit {
        periodicJokeWorker.stopPeriodicJokeFetch()
    }
}

// MARK: Interface conformations
extension JokesListPresenter: JokesListPresentable {
    func viewDidLoad() {
        Task {
            /// Fetch persisted jokes (if any) and ask view to display them
            if let persistedJokes = try? await jokesPersistor.getPersistedJokes() {
                persistedJokes.forEach {
                    jokes.pushJoke($0)
                }
                
                DispatchQueue.main.async {
                    self.view?.refreshJokesList()
                }
            }
        }
        
        /// register a listener that will instruct the view to insert a new row whenever a new joke arrives from the remote API
        periodicJokeWorker.freshJokeListener = { [weak self] newJoke in
            guard let self = self else {
                return
            }
            let currentJokeCount = self.jokeCount
            self.jokes.pushJoke(newJoke)
            let newJokeCount = self.jokeCount
            let shouldReplaceOldRow = currentJokeCount == newJokeCount
            
            DispatchQueue.main.async {
                self.view?.display(aJoke: newJoke,
                                   atIndex: self.jokeCount-1,
                                   whileReplacingOldJoke: shouldReplaceOldRow)
                
                if shouldReplaceOldRow {
                    self.view?.refreshVisibleRows()
                }
            }
        }
        
        periodicJokeWorker.startFetchingJokesPeriodically()
    }
    
    func handleApplicationWillResignActive() {
        /// called when application is about to become inactive. This can be a good time to save latest set of in-memory jokes to the disk
        saveJokesInPersistentStore()
        jokesPersistor.writeChanges()
    }
    
    private func saveJokesInPersistentStore() {
        do {
            try jokesPersistor.clearSavedJokes()
            let allJokes = jokes.allJokes
            try jokesPersistor.saveJokes(allJokes)
        } catch (let e) {
            print(e) // Log this somewhere for post release monitoring
        }
    }
}

