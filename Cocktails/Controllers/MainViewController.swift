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
    
    /// Category cell height size
    private let categoryCellHeight: CGFloat = 200
    
    /// Cocktail cell height size
    private let cocktailCellHeight: CGFloat = 110
    
    /// Cocktail cell top inset
    private let cocktailCellTopInset: CGFloat = 100
    
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    /// Create search results label
    private let searchResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "Search results:"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Main view controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: categoryIdentifier)
        collectionView.register(CocktailCollectionViewCell.self, forCellWithReuseIdentifier: cocktailIdentifier)
        setupNavigationBar()
        setupConstraintsForCollectionView()
        setupSearchResultsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let cocktails = self.cocktails else { return }
        updateData(cocktails: cocktails)
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
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    /// Add search results label and setup constraints
    private func setupSearchResultsLabel() {
        collectionView.addSubview(searchResultsLabel)
        searchResultsLabel.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: categoryCellHeight + cocktailCellTopInset / 2).isActive = true
        searchResultsLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        searchResultsLabel.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 15).isActive = true
        searchResultsLabel.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -15).isActive = true
    }
    
    // MARK: - Update data
    
    /// Refreshes the data for the latest
    /// - Parameter cocktails: Data to be updated
    private func updateData(cocktails: [Cocktail]) {
        realmService.synchronizeData(cocktails: cocktails)
        collectionView.reloadData()
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
            return .init(width: view.bounds.width - 2 * padding, height: cocktailCellHeight)
        }
        return .init(width: view.bounds.width, height: categoryCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: cocktailCellTopInset, left: padding, bottom: 0, right: padding)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        searchController.isActive = false
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
