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
    var jokeCount: Int { get }
    
    func viewDidLoad()
    func getJoke(atIndex index: Int) -> String
}


fileprivate let JOKE_CELL_REUSEID = "joke-cell"

final class JokesListViewController: UIViewController {
    var presenter: JokesListPresentable
    
    private lazy var tableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.dataSource = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: JOKE_CELL_REUSEID)
        t.estimatedRowHeight = 100
        return t
    }()
    
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
        presenter.viewDidLoad()
    }
    
    override func loadView() {
        let v = UIView()
        v.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: v.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: v.trailingAnchor)
        ])
        
        view = v
    }
}

// MARK: Interface conformations
extension JokesListViewController: JokesListInterface {
    func display(aJoke joke: String, atIndex index: Int, whileReplacingOldJoke: Bool) {
        tableView.beginUpdates()
        let indexPath = IndexPath(row: index, section: 0)
        
        if whileReplacingOldJoke {
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        
        tableView.insertRows(at: [indexPath], with: .right)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func refreshVisibleRows() {
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows?.dropLast(1) {
            tableView.reloadRows(at: Array(visibleIndexPaths), with: .automatic)
        }
    }
}

// MARK: UITableViewDataSource conformations
extension JokesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.jokeCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JOKE_CELL_REUSEID, for: indexPath)
        let joke = presenter.getJoke(atIndex: indexPath.row)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = joke
        return cell
    }
}

// MARK: UITableViewDelegate conformations
extension JokesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
