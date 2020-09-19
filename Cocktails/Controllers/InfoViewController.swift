//
//  InfoViewController.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 6/26/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit

protocol InfoViewControllerDelegate {
    func updateFavoriteStatus()
}

class InfoViewController: UIViewController {
    
    // MARK: - Info view controller instances
    
    /// Delegate of info view controller
    public var delegate: InfoViewControllerDelegate?
    
    /// Singleton object of class Realm Service
    private let realmService = RealmService.shared
    
    /// Synchronizes favorite status between two different objects
    public var updateFavoriteStatus: (() -> Void)?
    
    /// Cocktail object to be displayed
    public var cocktail: CocktailProtocol? {
        didSet {
            setData()
        }
    }
    
    // MARK: - Creating UI elements
    
    /// Create layout view
    private let layoutView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Create cocktail image view
    private let cocktailImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    /// Create cocktail name label
    private let cocktailName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Create cocktail description label
    private let cocktailDescription: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Create favorite button
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Create activity indicator for image
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Info view controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraintsForLayoutView()
        setupConstraintsForCocktailImage()
        setupConstraintsForCocktailName()
        setupConstraintsForCocktailDescription()
        setupConstraintsForFavoriteButton()
        setupConstraintsForActivityIndicator()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateFavoriteStatus?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cocktail = cocktail {
            guard let isFavorite = realmService.getObjects(CocktailRealm.self).filter({$0.strDrink == cocktail.strDrink}).first else { return }
            setImageForFavoriteButton(isFavorite: isFavorite.isFavorite)
        }
    }
    
    // MARK: - Adding UI elements and setting constraints
    
    /// Adding layout view and setup constraints
    private func setupConstraintsForLayoutView() {
        view.addSubview(layoutView)
        layoutView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        layoutView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        layoutView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        layoutView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5).isActive = true
    }
    
    /// Adding coctail image and setup constraints
    private func setupConstraintsForCocktailImage() {
        layoutView.addSubview(cocktailImage)
        cocktailImage.topAnchor.constraint(equalTo: layoutView.topAnchor).isActive = true
        cocktailImage.leadingAnchor.constraint(equalTo: layoutView.leadingAnchor).isActive = true
        cocktailImage.trailingAnchor.constraint(equalTo: layoutView.trailingAnchor).isActive = true
        cocktailImage.heightAnchor.constraint(equalTo: layoutView.heightAnchor).isActive = true
    }
    
    /// Adding cocktail name and setup constraints
    private func setupConstraintsForCocktailName() {
        view.addSubview(cocktailName)
        cocktailName.topAnchor.constraint(equalTo: cocktailImage.bottomAnchor, constant: 15).isActive = true
        cocktailName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        cocktailName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        cocktailName.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    /// Adding cocktail description and setup constraints
    private func setupConstraintsForCocktailDescription() {
        view.addSubview(cocktailDescription)
        cocktailDescription.topAnchor.constraint(equalTo: cocktailName.bottomAnchor, constant: 10).isActive = true
        cocktailDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        cocktailDescription.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        cocktailDescription.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    /// Adding favorite button and setup constraints
    private func setupConstraintsForFavoriteButton() {
        view.addSubview(favoriteButton)
        favoriteButton.addTarget(self, action: #selector(changeFavoriteStatus), for: .touchUpInside)
        favoriteButton.topAnchor.constraint(equalTo: cocktailImage.topAnchor, constant: 25).isActive = true
        favoriteButton.trailingAnchor.constraint(equalTo: cocktailImage.trailingAnchor, constant: -25).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        favoriteButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    /// Adding activity indicator and setup constraints
    private func setupConstraintsForActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: cocktailImage.topAnchor, constant: 90).isActive = true
    }
    
    // MARK: - Info view controller methods for adding data
    
    /// Adds cocktail data to the info view controller
    private func setData() {
        guard let drink = cocktail else { return }
        let isFavorite = drink.isFavorite
        downloadImage(url: drink.strDrinkThumb)
        setImageForFavoriteButton(isFavorite: isFavorite)
        cocktailName.text = drink.strDrink
        cocktailDescription.text = drink.strInstructions
    }
    
    /// Download a cocktail image at the specified url
    /// - Parameter url: URL where the image will be loaded
    private func downloadImage(url: String) {
        guard let request = CocktailRequest.image(url: url).request else { return }
        NetworkManager(request: request).downloadImage { [weak self] image in
            self?.cocktailImage.image = image
            self?.activityIndicator.stopAnimating()
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
        guard let drink = cocktail else { return }
        let isFavorite = !drink.isFavorite
        realmService.setData(cocktail: drink, isFavorite: isFavorite)
        setImageForFavoriteButton(isFavorite: isFavorite)
        delegate?.updateFavoriteStatus()
    }
}

