//
//  TableViewCell.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 7/21/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit

class CocktailTableViewCell: UITableViewCell {
    
    // MARK: - Cocktail table cell instances
    
    /// Singleton object of class Realm Service
    private let realmService = RealmService.shared
    
    /// Cocktail object to be displayed
    public var cocktail: CocktailProtocol? {
        didSet {
            setData()
        }
    }
    
    // MARK: - Creating UI elements
    
    /// Create cocktail image view
    private let cocktailImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        image.contentMode = .scaleToFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    /// Create cocktail name label
    private let cocktailName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Create favorite button
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Cocktail table cell constructors
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraintsForCocktailImage()
        setupConstraintsForCocktailName()
        setupConstraintsForFavoriteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Adding UI elements and setting constraints
    
    /// Adding  coctail image and setup constraints
    private func setupConstraintsForCocktailImage() {
        contentView.addSubview(cocktailImage)
        cocktailImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25).isActive = true
        cocktailImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        cocktailImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cocktailImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    /// Adding  cocktail name and setup constraints
    private func setupConstraintsForCocktailName() {
        contentView.addSubview(cocktailName)
        cocktailName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        cocktailName.leadingAnchor.constraint(equalTo: cocktailImage.trailingAnchor, constant: 15).isActive = true
        cocktailName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -80).isActive = true
        cocktailName.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
    /// Adding cocktail description and setup constraints
    private func setupConstraintsForFavoriteButton() {
        contentView.addSubview(favoriteButton)
        favoriteButton.addTarget(self, action: #selector(changeFavoriteStatus), for: .touchUpInside)
        favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35).isActive = true
        favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        favoriteButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    // MARK: - Cocktail table cell methods for adding data
    
    /// Adds cocktail data to the cell
    private func setData() {
        guard let drink = self.cocktail else { return }
        let isFavorite = drink.isFavorite
        cocktailName.text = drink.strDrink
        downloadImage(url: drink.strDrinkThumb)
        setImageForFavoriteButton(isFavorite: isFavorite)
    }
    
    /// Download a cocktail image at the specified url
    /// - Parameter url: URL where the image will be loaded
    private func downloadImage(url: String) {
        guard let request = CocktailRequest.image(url: url).request else { return }
        NetworkManager(request: request).downloadImage { [weak self] image in
            self?.cocktailImage.image = image
        }
    }
    
    /// Sets the image for favorite button
    /// - Parameter isFavorite: Is the cocktail is favorite
    private func setImageForFavoriteButton(isFavorite: Bool) {
        let image = isFavorite ? UIImage(named: CellIdentifier.favorite) : UIImage(named: CellIdentifier.unfavorite)
        favoriteButton.setImage(image, for: .normal)
    }
    
    /// Changes the favorite status when click on the button
    @objc private func changeFavoriteStatus() {
        guard var drink = self.cocktail else { return }
        guard let request = CocktailRequest.searchByName(name: drink.strDrink).request else { return }
        drink.isFavorite = !drink.isFavorite
        
        NetworkManager(request: request).downloadCocktails { [weak self] cocktails in
            guard let cocktail = cocktails?.first else { return }
            self?.realmService.setData(cocktail: cocktail, isFavorite: drink.isFavorite)
        }
        setImageForFavoriteButton(isFavorite: drink.isFavorite)
    }
}
