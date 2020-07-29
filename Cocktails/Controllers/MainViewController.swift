//
//  MainVViewController.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 7/9/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Main view controller instances
    
    /// Padding for collection view cells
    private let padding: CGFloat = 16
    
    /// Identifiers for cells
    private let categoryIdentifier = "category"
    private let cocktailIdentifier = "cocktail"
    
    /// Stores downloaded cocktails from the network
    public var cocktails: [Cocktail]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    /// Singleton object of class Realm Service
    private let realmService = RealmService.shared
    
    // MARK: - Creating UI elements
    
    /// Create search controller
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search cocktails by name"
        return searchController
    }()
    
    /// Create collection view
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Main view controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tabBarController?.delegate = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: categoryIdentifier)
        collectionView.register(CocktailCollectionViewCell.self, forCellWithReuseIdentifier: cocktailIdentifier)
        setupNavigationBar()
        setupConstraintsForCollectionView()
    }
    
    // MARK: - Adding UI elements and setting constraints
    
    /// Setup navigation bar
    private func setupNavigationBar() {
        title = "Categoryes"
        searchController.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
    }
    
    /// Add collection view and setup constraints
    private func setupConstraintsForCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    // MARK: - Update data
    
    /// Refreshes the data for the latest
    /// - Parameters:
    ///   - controller: The controller in which the data will be updated
    ///   - cocktails: Data to be updated
    private func updateDataIn(controller: InfoViewControllerDelegate, cocktails: [Cocktail]) {
        realmService.deleteUnfavoriteCocktailsFromStorage()
        realmService.synchronizeData(cocktails: cocktails)
        controller.updateFavoriteStatus()
    }
}

// MARK: - CollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let infoViewController = InfoViewController()
        infoViewController.cocktail = cocktails?[indexPath.row]
        infoViewController.delegate = self
        navigationController?.pushViewController(infoViewController, animated: true)
    }
}

// MARK: - CollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return cocktails?.count ?? 0
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cocktailIdentifier, for: indexPath) as? CocktailCollectionViewCell else { return UICollectionViewCell() }
            cell.cocktail = cocktails?[indexPath.row]
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryIdentifier, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        cell.delegate = self
        return cell
    }
}

// MARK: - CollectionViewDelegateFlowLayout

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            return .init(width: view.bounds.width - 2 * padding, height: 110)
        }
        return .init(width: view.bounds.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0)
    }
}

// MARK: - SearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let request = CocktailRequest.searchByName(name: searchText).request else { return }
        NetworkManager(request: request).downloadCocktails { [weak self] cocktails in
            if let cocktails = cocktails {
                self?.cocktails = cocktails
                self?.realmService.synchronizeData(cocktails: cocktails)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

// MARK: - TabBarControllerDelegate

extension MainViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        guard let navigationController = viewController as? UINavigationController else { return }
        
        if  navigationController.topViewController is MainViewController {
            guard let cocktails = self.cocktails else { return }
            updateDataIn(controller: self, cocktails: cocktails)
        }
        
        if let favoriteController = navigationController.topViewController as? FavoriteViewController {
            realmService.deleteUnfavoriteCocktailsFromStorage()
            favoriteController.drinks = realmService.getObjects(CocktailRealm.self)
            favoriteController.updateFavoriteStatus()
        }
        
        if let cocktailsController = navigationController.topViewController as? CocktailsViewController {
            guard let cocktails = cocktailsController.cocktails else { return }
            updateDataIn(controller: cocktailsController, cocktails: cocktails)
        }
    }
}

// MARK: - CategoryCollectionViewCellProtocol

extension MainViewController: CollectionViewCellProtocol {
    
    func pushNavigation(controller: UIViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func synhronizeData() {
        guard let cocktails = self.cocktails else { return }
        self.realmService.synchronizeData(cocktails: cocktails)
        collectionView.reloadData()
    }
}

// MARK: - InfoViewControllerDelegate

extension MainViewController: InfoViewControllerDelegate {
    func updateFavoriteStatus() {
        collectionView.reloadData()
    }
}
