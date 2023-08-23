//
//  JokesListBuilder.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import Foundation

protocol JokesListBuildable {
    func buildModule() -> JokesListInterface
}

final class JokesListBuilder: JokesListBuildable {
    func buildModule() -> JokesListInterface {
        var presenter: JokesListPresentable = JokesListPresenter()
        let view = JokesListViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
