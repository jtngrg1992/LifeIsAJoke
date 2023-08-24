//
//  JokesListBuilder.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import Foundation

protocol JokesListBuildable {
    func buildModule(jokeUpdateInterval: TimeInterval, maxJokeCount: Int) -> JokesListInterface
}

final class JokesListBuilder: JokesListBuildable {
    private let networkService: NetworkServicing
    private let coreDataManager: CoreDataManaging
    
    init(networkService: NetworkServicing, coreDataManager: CoreDataManaging) {
        self.networkService = networkService
        self.coreDataManager = coreDataManager
    }
    
    func buildModule(jokeUpdateInterval: TimeInterval, maxJokeCount: Int) -> JokesListInterface {
        let jokeFetcher = JokeFetcher(networkService: networkService)
        let periodicJokeFetcher = PeriodicJokeWorker(jokeFetcher: jokeFetcher,
                                                     fetchInterval: jokeUpdateInterval)
        let jokesPersistor = JokesPersistentWorker(coreDataManager: coreDataManager)
        var presenter: JokesListPresentable = JokesListPresenter(periodicJokeWorker: periodicJokeFetcher,
                                                                 maxJokeCount: maxJokeCount,
                                                                 jokesPersistor: jokesPersistor)
        let view = JokesListViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
