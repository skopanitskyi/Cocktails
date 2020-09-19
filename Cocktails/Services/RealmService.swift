//
//  RealmService.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 6/27/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import Foundation
import RealmSwift

/// Helps to save, delete, update, receive data from the device’s internal memory
class RealmService {
    
    // MARK: - Realm service class instances
    
    /// Type of objects used
    private let type = CocktailRealm.self
    
    /// Singleton object of class Realm Service
    public static let shared = RealmService()
    
    /// Realm structure instance
    private let realm = try! Realm()
    
    // MARK: - Realm service class constructor
    
    /// Private realm service class constructor
    private init() { deleteUnfavoriteCocktailsFromStorage() }
    
    // MARK: - Realm service class methods
    
    /// Adds the specified object to the device’s memory
    /// - Parameter object: The object to be added to the device memory
    private func add<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print(error)
        }
    }
    
    /// Updates the specified object in the device memory
    /// - Parameters:
    ///   - name: The name of the cocktail to be updated
    ///   - isFavorite: Is the cocktail is favorite
    private func update(by name: String, isFavorite: Bool) {
        guard let cocktail = getCocktail(by: name) else { return }
        
        do {
            try realm.write {
                cocktail.isFavorite = isFavorite
            }
        } catch {
            print(error)
        }
    }
    
    /// Deletes the specified object in the device’s memory.
    /// - Parameter object: The object to be removed from memory
    private func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    /// Returns all objects that are stored in device memory
    /// - Parameter type: Return objects type
    public func getObjects<T: Object>(_ type: T.Type) -> [T] {
        return Array(realm.objects(type))
    }
    
    /// Updates objects stored in memory or adds new ones
    /// - Parameters:
    ///   - cocktail: Cocktail to be added or updated
    ///   - isFavorite: Is the cocktail is favorite
    public func setData(cocktail: CocktailProtocol, isFavorite: Bool) {
        var cocktail = cocktail
        
        if cocktail is CocktailRealm {
            update(by: cocktail.strDrink, isFavorite: isFavorite)
        } else if isStored(name: cocktail.strDrink) {
            update(by: cocktail.strDrink, isFavorite: isFavorite)
            cocktail.isFavorite = isFavorite
        } else {
            cocktail.isFavorite = isFavorite
            guard let cocktail = createRealmCocktail(cocktail: cocktail, isFavorite: isFavorite) else { return }
            add(cocktail)
        }
    }
    
    /// Creates a cocktail realm object that will be stored in memory
    /// - Parameters:
    ///   - cocktail: Cocktail object that contains data
    ///   - isFavorite: Is the cocktail is favorite
    private func createRealmCocktail(cocktail: CocktailProtocol, isFavorite: Bool) -> CocktailRealm? {
        return CocktailRealm(strDrink: cocktail.strDrink,
                             strDrinkThumb: cocktail.strDrinkThumb,
                             strInstructions: cocktail.strInstructions,
                             isFavorite: isFavorite)
    }
    
    /// Check if the cocktail is stored in memory by the given name
    /// - Parameter name: The name of the cocktail to be searched for in memory
    private func isStored(name: String) -> Bool {
        if let _ = getCocktail(by: name) {
            return true
        }
        return false
    }
    
    /// Returns the cocktail object stored in memory
    /// - Parameter name: Name of the cocktail to be returned
    private func getCocktail(by name: String) -> CocktailRealm? {
        return getObjects(type).filter({ $0.strDrink == name }).first
    }
    
    /// Synchronizes the data of downloaded and saved cocktails
    /// - Parameter cocktails: Cocktails that have been downloaded
    public func synchronizeData(cocktails: [Cocktail]) {
        let savedCocktails = getObjects(type)
        
        for cocktail in cocktails {
            synchronizeFavoriteStatus(cocktail: cocktail, savedCocktails: savedCocktails)
        }
    }
    
    /// Synchronizes favorite status between cocktails
    /// - Parameters:
    ///   - cocktail: Cocktail that have been downloaded
    ///   - savedCocktails: Saved cocktails in the device memory
    private func synchronizeFavoriteStatus(cocktail: Cocktail, savedCocktails: [CocktailRealm]) {
        for savedCocktail in savedCocktails {
            if cocktail.strDrink == savedCocktail.strDrink && savedCocktail.isFavorite {
                cocktail.isFavorite = true
                return
            }
        }
        cocktail.isFavorite = false
    }
    
    /// Removes unfavorite cocktails from devices memory
    private func deleteUnfavoriteCocktailsFromStorage() {
        let savedCocktails = getObjects(type)
        for cocktail in savedCocktails {
            if !cocktail.isFavorite {
                delete(cocktail)
            }
        }
    }
}
