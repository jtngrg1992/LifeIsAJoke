//
//  JokesListPresenter.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import Foundation


protocol JokesListView: NSObject {
    var presenter: JokesListPresentable { get }
    
    func displayNewJoke(newJoke: String)
}

final class JokesListPresenter {
    weak var view: JokesListView?
    var jokeCount: Int {
        jokes.length
    }
    
    private let jokes: JokeList<String>
    private var periodicJokeWorker: PeriodicJokeWorking
    
    init(periodicJokeWorker: PeriodicJokeWorking, maxJokeCount: Int) {
        self.periodicJokeWorker = periodicJokeWorker
        self.jokes = JokeList<String>(maxJokeCount)
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
        periodicJokeWorker.freshJokeListener = { [weak self] newJoke in
            guard let self = self else {
                return
            }
            
            self.jokes.pushJoke(newJoke)
            self.view?.displayNewJoke(newJoke: newJoke)
        }
        
        periodicJokeWorker.startFetchingJokesPeriodically()
    }
}

