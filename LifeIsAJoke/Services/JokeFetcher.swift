//
//  JokeFetcher.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 24/08/23.
//

import Foundation

protocol JokeFetchable {
    func fetchAJoke() async throws -> String
}

/// A very simple worker that utilizes network service to fetch a single joke from remote jokes API.
/// Inject mocked networkService object while unit testing

final class JokeFetcher: JokeFetchable {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing) {
        self.networkService = networkService
    }
    
    func fetchAJoke() async throws -> String {
        let networkRequest = GetNetWorkRequest(requestURL: API.jokeAPI, queryParams: nil)
        let joke: String = try await networkService.execute(networkRequest: networkRequest)
        return joke
    }
}
