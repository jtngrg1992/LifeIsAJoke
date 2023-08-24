//
//  JokeStack.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 24/08/23.
//

import Foundation

class JokeList<T> {
    private var jokesArr: [T]
    private let listSize: Int
    
    
    var length: Int {
        jokesArr.count
    }
    
    init(_ stackSize: Int) {
        self.jokesArr = []
        self.listSize = stackSize
    }
    
    func pushJoke(_ newJoke: T) {
        jokesArr.append(newJoke)
        if jokesArr.count > listSize {
            let diff = jokesArr.count - listSize
            let trimmedArray = jokesArr.dropFirst(diff)
            jokesArr = Array(trimmedArray)
        }
    }
    
    func getJoke(atIndex index: Int) -> T? {
        guard jokesArr.indices.contains(index) else {
            return nil
        }
        return jokesArr[index]
    }
}
