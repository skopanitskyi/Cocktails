//
//  CollectionViewCell.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 7/20/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit

class CocktailCollectionViewCell: UICollectionViewCell {
    
    // MARK: - collection cell instances
    
    /// Cocktail object to be displayed
    public var cocktail: Cocktail? {
        didSet {
            setData()
        }
    }
    
    /// Singleton object of class Realm Service
    private let realmService = RealmService.shared
    
    // MARK: - Creating UI elements
    
    /// Create cocktail image view
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Create cocktail name label
    private let textLabel: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .left
        lable.font = UIFont.boldSystemFont(ofSize: 12)
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    /// Create cocktail description label
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Create cocktail favorite button
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: CellIdentifier.unfavorite), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - collection cell constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageViewSetupConstraints()
        setupConstraintsForFavoriteButton()
        textLabelSetupConstraints()
        descriptionLabelSetupConstraints()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 5, height: 8)
        clipsToBounds = false
    }
    
    // MARK: - Adding UI elements and setting constraints
    
    /// Adding cocktail image view and setup constraints
    private func imageViewSetupConstraints() {
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    /// Adding cocktail name label and setup constraints
    private func textLabelSetupConstraints() {
        contentView.addSubview(textLabel)
        textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 25).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -20).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
    /// Adding cocktail description label and setup constraints
    private func descriptionLabelSetupConstraints() {
        contentView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 25).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -20).isActive = true
    }
    
    /// Adding cocktail favorite button and setup constraints
    private func setupConstraintsForFavoriteButton() {
        contentView.addSubview(favoriteButton)
        favoriteButton.addTarget(self, action: #selector(changeFavoriteStatus), for: .touchUpInside)
        favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35).isActive = true
        favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        favoriteButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    // MARK: - collection cell methods for adding data
    
    /// Sets the image for favorite button
    /// - Parameter isFavorite: Is the cocktail is favorite
    private func setImageForFavoriteButton(isFavorite: Bool) {
        let image = isFavorite ? UIImage(named: CellIdentifier.favorite) : UIImage(named: CellIdentifier.unfavorite)
        favoriteButton.setImage(image, for: .normal)
    }
    
    /// Changes the favorite status when click on the button
    @objc private func changeFavoriteStatus() {
        guard let drink = self.cocktail else { return }
        let isFavorite = !drink.isFavorite
        realmService.updateCocktailData(cocktail: drink, isFavorite: isFavorite)
        setImageForFavoriteButton(isFavorite: drink.isFavorite)
    }
    
    /// Adds cocktail data to the cell
    private func setData() {
        guard let drink = self.cocktail else { return }
        let isFavorite = drink.isFavorite
        textLabel.text = drink.strDrink
        descriptionLabel.text = drink.strInstructions
        downloadImage(url: drink.strDrinkThumb)
        setImageForFavoriteButton(isFavorite: isFavorite)
    }
    
    /// Download a cocktail image at the specified url
    /// - Parameter url: URL where the image will be loaded
    private func downloadImage(url: String) {
        guard let request = CocktailRequest.image(url: url).request else { return }
        NetworkManager(request: request).downloadImage { [weak self] image in
            self?.imageView.image = image
        }
    }
}
