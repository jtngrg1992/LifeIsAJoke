//
//  PeriodicJokeWorker.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 24/08/23.
//

import Foundation

/// To allow moking of a `Timer` object while unit testing `PeriodicJokeWorker`
protocol TimerInterface {
    static func scheduledTimer(withTimeInterval interval: TimeInterval,
                               repeats: Bool, block: @escaping @Sendable (Timer) -> Void) -> Timer
    func invalidate()
}

extension Timer: TimerInterface {
    
}

protocol PeriodicJokeWorking {
    var freshJokeListener: ((_ joke: String) -> Void)? { get set }
    
    func startFetchingJokesPeriodically()
    func stopPeriodicJokeFetch()
}

/// A simple class that will periodically fetch a new joke use JokeFetcher and dump it on the `freshJokeListener` block
final class PeriodicJokeWorker: PeriodicJokeWorking {
    private let fetchInterval: TimeInterval
    private let jokeFetcher: JokeFetchable
    private var timer: TimerInterface?
    private var hasWorkStarted = false
    
    var freshJokeListener: ((_ joke: String) -> Void)?
    
    init(jokeFetcher: JokeFetchable, fetchInterval: TimeInterval, timer: TimerInterface? = nil) {
        self.timer = timer
        self.fetchInterval = fetchInterval
        self.jokeFetcher = jokeFetcher
    }
    
    func startFetchingJokesPeriodically() {
        guard !hasWorkStarted else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: fetchInterval, repeats: true,
                                     block: { [weak self] _ in
            guard let self = self else {
                return
            }
            Task {
                let newJoke: String? = try await self.jokeFetcher.fetchAJoke()
                if let newJoke = newJoke {
                    self.freshJokeListener?(newJoke)
                }
            }
        })
        
        hasWorkStarted = true
    }
    
    func stopPeriodicJokeFetch() {
        defer {
            cleanTimer()
            hasWorkStarted = false
        }
        
        guard hasWorkStarted  else {
            return
        }
    }
    
    private func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
}
