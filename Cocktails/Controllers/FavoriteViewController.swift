//
//  FavoriteViewController.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 6/26/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController {
    
    // MARK: - Favorite view controller instances
    
    /// Stores saved cocktails
    public var drinks = [CocktailRealm]()
    
    /// Singleton object of class Realm Service
    private let realmService = RealmService.shared
    
    // MARK: - Creating UI elements
    
    /// Create table view
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Favorite view controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Favorite"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupConstraintsForTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drinks = realmService.getObjects(CocktailRealm.self).filter { $0.isFavorite }
        tableView.reloadData()
    }
    
    // MARK: - Adding UI elements and setting constraints
    
    /// Adding table view and setup constraints
    private func setupConstraintsForTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: CellIdentifier.identifier)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}

// MARK: - TableViewDelegate

extension FavoriteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoController = InfoViewController()
        
        infoController.updateFavoriteStatus = { [weak self] in
            self?.tableView.reloadData()
        }
        
        infoController.cocktail = drinks[indexPath.row]
        navigationController?.pushViewController(infoController, animated: true)
    }
}

// MARK: - TableViewDataSource

extension FavoriteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.identifier, for: indexPath) as? FavoriteTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.cocktail = drinks[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - InfoViewControllerDelegate
extension FavoriteViewController: CellDelegate {
    
    func updateFavoriteStatus(cocktail: CocktailRealm) {
        guard let index = drinks.firstIndex(of: cocktail) else { return }
        drinks.remove(at: index)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .right)
        tableView.endUpdates()
    }
}

