//
//  RealmModel.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 7/1/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import Foundation
import RealmSwift

/// Represents a cocktail data model that is stored in device memory
class CocktailRealm: Object, CocktailProtocol {
    @objc dynamic var strDrink: String = ""
    @objc dynamic var strDrinkThumb: String = ""
    @objc dynamic var strInstructions: String? = ""
    @objc dynamic var isFavorite: Bool = true
    
    convenience init?(strDrink: String, strDrinkThumb: String, strInstructions: String?, isFavorite: Bool) {
        self.init()
        self.strDrink = strDrink
        self.strDrinkThumb = strDrinkThumb
        self.strInstructions = strInstructions
        self.isFavorite = isFavorite
    }
}
