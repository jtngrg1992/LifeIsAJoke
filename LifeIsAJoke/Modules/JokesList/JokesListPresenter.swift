//
//  JokesListPresenter.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import Foundation


protocol JokesListView: NSObject {
    var presenter: JokesListPresentable { get }
}

final class JokesListPresenter {
    weak var view: JokesListView?
}

// MARK: Interface conformations
extension JokesListPresenter: JokesListPresentable {
    
}
