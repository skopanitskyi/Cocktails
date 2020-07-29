//
//  CategoryCollectionViewCell.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 7/9/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit

protocol CollectionViewCellProtocol {
    func pushNavigation(controller: UIViewController)
    func synhronizeData()
}

class CollectionViewCell: UICollectionViewCell {
    
    // MARK: - Collection view cell instances
    
    /// Padding for collection view cells
    private let padding: CGFloat = 14
    
    /// Available cocktail categories
    private let categoryes = ["Beer", "Cocktail", "Cocoa", "Coffee / Tea", "Homemade Liqueur", "Ordinary Drink", "Other/Unknown", "Punch / Party Drink", "Shot", "Soft Drink / Soda"]
    
    /// Delegate of category collection view cell
    public var delegate: CollectionViewCellProtocol?
    
    // MARK: - Creating UI elements
    
    /// Create collection view 
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 30
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Collection view cell constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewSetupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Adding UI elements and setting constraints

    /// Adding collection view and setup constraints
    private func collectionViewSetupConstraints() {
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

// MARK: - CollectionViewDelegate

extension CollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let request = CocktailRequest.serchByCategory(category: categoryes[indexPath.row]).request else { return }
        let cocktailsController = CocktailsViewController()
        cocktailsController.categoryes = categoryes[indexPath.row]
        cocktailsController.delegate = delegate
        NetworkManager(request: request).downloadCocktails { cocktails in
            cocktailsController.cocktails = cocktails
        }
        delegate?.pushNavigation(controller: cocktailsController)
    }
}

// MARK: - CollectionViewDataSource

extension CollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.identifier, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = UIImage(named: CellIdentifier.drink)
        cell.textLabel.text = categoryes[indexPath.row]
        return cell
    }
}

// MARK: - CollectionViewDelegateFlowLayout

extension CollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: frame.height - padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
}
