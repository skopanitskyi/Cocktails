//
//  CocktailModel.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 6/28/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import Foundation

protocol CocktailProtocol {
    var strDrink: String { get }
    var strDrinkThumb: String { get }
    var strInstructions: String? { get }
    var isFavorite: Bool { get set }
}

/// Represents a cocktail data model that is used when downloading data from the Internet
class Cocktail: CocktailProtocol {
    
    // MARK: - Cocktail class instances
    
    /// Cocktail name
    public let strDrink: String
    
    /// Cocktail image url
    public let strDrinkThumb: String
    
    /// Cocktail instructions
    public let strInstructions: String?
    
    /// Indicates this is favorite cocktail
    public var isFavorite: Bool
    
    // MARK: - Keys for cocktails dictionary
    
    /// Stores keys by which data is obtained from the dictionary
    private struct ApiKeys {
        public static let name = "strDrink"
        public static let image = "strDrinkThumb"
        public static let instructions = "strInstructions"
    }
    
    // MARK: - Cocktail class constructor
    
    /// Cocktail class constructor
    init?(dictionary: [String: Any]) {
        guard let strDrink = dictionary[ApiKeys.name] as? String,
              let strDrinkThumb = dictionary[ApiKeys.image] as? String else {
                return nil
        }
        self.strDrink = strDrink
        self.strDrinkThumb = strDrinkThumb
        self.strInstructions = dictionary[ApiKeys.instructions] as? String
        self.isFavorite = false
    }
}
