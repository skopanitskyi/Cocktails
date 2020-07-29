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
    private init() { }
    
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
        guard let object = getObjects(type).filter({$0.strDrink == name}).first else { return }
        do {
            try realm.write {
                object.isFavorite = isFavorite
            }
        } catch {
            print(error)
        }
    }
    
    /// Deletes the specified object in the device’s memory.
    /// - Parameter object: The object to be removed from memory
    public func delete<T: Object>(_ object: T) {
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
    public func getObjects<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    /// Updates or deletes the data of the specified cocktail in the device memory
    /// - Parameters:
    ///   - cocktail: Cocktail object whose data will be deleted or updated
    ///   - isFavorite: Is the cocktail is favorite
    public func updateCocktailData(cocktail: CocktailProtocol?, isFavorite: Bool) {
        guard var cocktail = cocktail else { return }
        
        if cocktail is CocktailRealm {
            update(by: cocktail.strDrink, isFavorite: isFavorite)
        } else {
            addOrDeleteCocktailFromStorage(cocktail: cocktail, isFavorite: isFavorite)
            cocktail.isFavorite = isFavorite
        }
    }
    
    /// Adds or removes cocktails from memory depending on favorite status
    /// - Parameters:
    ///   - cocktail: Cocktail object to be removed or added to internal storage
    ///   - isFavorite: Is the cocktail is favorite
    private func addOrDeleteCocktailFromStorage(cocktail: CocktailProtocol, isFavorite: Bool) {
        if isFavorite {
            let cocktailRealm = CocktailRealm()
            cocktailRealm.strDrink = cocktail.strDrink
            cocktailRealm.strDrinkThumb = cocktail.strDrinkThumb
            cocktailRealm.strInstructions = cocktail.strInstructions
            cocktailRealm.isFavorite = isFavorite
            add(cocktailRealm)
        } else {
            guard let cocktailForDelete = getObjects(type).filter({$0.strDrink == cocktail.strDrink}).first else { return }
            delete(cocktailForDelete)
        }
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
    private func synchronizeFavoriteStatus(cocktail: Cocktail, savedCocktails: Results<CocktailRealm>) {
        for savedCocktail in savedCocktails {
            if cocktail.strDrink == savedCocktail.strDrink {
                cocktail.isFavorite = true
                return
            }
        }
        cocktail.isFavorite = false
    }
    
    /// Removes unfavorite cocktails from devices memory
    public func deleteUnfavoriteCocktailsFromStorage() {
        let savedCocktails = getObjects(type)
        for cocktail in savedCocktails {
            if !cocktail.isFavorite {
                delete(cocktail)
            }
        }
    }
}
