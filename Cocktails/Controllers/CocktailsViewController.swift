//
//  ViewController.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 6/26/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit

class CocktailsViewController: UIViewController {
    
    // MARK: - Cocktails view controller instances
    
    /// Singleton object of class Realm Service
    private let realmService = RealmService.shared
    
    /// Stores all loaded cocktails
    public var cocktails: [Cocktail]? {
        didSet {
            guard let cocktails = self.cocktails else { return }
            self.realmService.synchronizeData(cocktails: cocktails)
            self.tableView.reloadData()
        }
    }
    
    /// Category of displayed drinks
    public var categoryes: String?
    
    /// Delegate of category collection view cell
    public var delegate: CollectionViewCellProtocol?
    
    // MARK: - Creating UI elements
    
    /// Create table view
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Cocktails view controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = categoryes
        view.backgroundColor = .white
        setupConstraintsForTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.synhronizeData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    // MARK: - Adding UI elements and setting constraints
    
    /// Adding table view and setup constraints
    private func setupConstraintsForTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CocktailTableViewCell.self, forCellReuseIdentifier: CellIdentifier.identifier)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    ///
    ///
    ///
    ///
    private func updateData() {
        guard let cocktails = cocktails else { return }
        realmService.deleteUnfavoriteCocktailsFromStorage()
        realmService.synchronizeData(cocktails: cocktails)
        tableView.reloadData()
        print(realmService.getObjects(CocktailRealm.self))
    }
    
    // MARK: - Methods for working with the network
    
    /// Downloads the selected cocktail from the web with additional information
    /// - Parameters:
    ///   - name: Name of the selected cocktail
    ///   - completion: Provides downloaded data
    private func downloadSelectedCocktail(name: String, completion: @escaping (Cocktail) -> Void) {
        guard let request = CocktailRequest.searchByName(name: name).request else { return }
        NetworkManager(request: request).downloadCocktails { cocktail in
            if let cocktail = cocktail?.first {
                completion(cocktail)
            }
        }
    }
}

// MARK: - TableViewDataSource

extension CocktailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cocktails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.identifier, for: indexPath) as? CocktailTableViewCell else { return UITableViewCell() }
        cell.cocktail = cocktails?[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - TableViewDelegate

extension CocktailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let drink = cocktails?[indexPath.row] else { return }
        let infoController = InfoViewController()
        infoController.delegate = self
        
        downloadSelectedCocktail(name: drink.strDrink) { cocktail in
            infoController.cocktail = cocktail
            infoController.cocktail?.isFavorite = drink.isFavorite
        }
//        infoController.updateFavoriteStatus = { [weak self] in
////            self?.cocktails?[indexPath.row].isFavorite = favorite
//        }
        navigationController?.pushViewController(infoController, animated: true)
    }
}

// MARK: - InfoViewControllerDelegate

extension CocktailsViewController: InfoViewControllerDelegate {
    
    func updateFavoriteStatus() {
        tableView.reloadData()
    }
}
