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
    
    init(networkService: NetworkServicing) {
        self.networkService = networkService
    }
    
    func buildModule(jokeUpdateInterval: TimeInterval, maxJokeCount: Int) -> JokesListInterface {
        let jokeFetcher = JokeFetcher(networkService: networkService)
        let periodicJokeFetcher = PeriodicJokeWorker(jokeFetcher: jokeFetcher, fetchInterval: jokeUpdateInterval)
        var presenter: JokesListPresentable = JokesListPresenter(periodicJokeWorker: periodicJokeFetcher, maxJokeCount: maxJokeCount)
        let view = JokesListViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
