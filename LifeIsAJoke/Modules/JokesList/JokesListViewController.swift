//
//  JokesListViewController.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import UIKit

protocol JokesListInterface: UIViewController, JokesListView {
    
}

protocol JokesListPresentable {
    var view: JokesListView? { get set }
}


final class JokesListViewController: UIViewController {
    var presenter: JokesListPresentable
    
    init(presenter: JokesListPresentable) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}

// MARK: Interface conformations
extension JokesListViewController: JokesListInterface {
    
}
