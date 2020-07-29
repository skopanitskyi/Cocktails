//
//  NetworkRequest.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 6/28/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import UIKit

/// Handles network requests related to loading data and images
class NetworkManager {
    
    // MARK: - Network manager class instances
    
    /// Request for loading data
    private let request: URLRequest
    
    /// Singleton object of class Realm Service
    private let realmService = RealmService.shared
    
    // MARK: - Network manager class constructor
    
    /// Network manager class constructor
    /// - Parameter request: Request for downloading data from the internet
    init(request: URLRequest) {
        self.request = request
    }
    
    // MARK: - Network manager class methods
    
    /// Downloads data for a specified request and converts them into a Cocktail model
    /// - Parameter completion: Provides downloaded data
    public func downloadCocktails(completion: @escaping ([Cocktail]?) -> ()) {
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    completion(nil)
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                    let cocktailsDictionaries = json["drinks"] as? [[String : Any]] else {
                        completion(nil)
                        return
                }
                let cocktails = cocktailsDictionaries.compactMap({ cocktail in
                    return Cocktail(dictionary: cocktail)
                })
                completion(cocktails)
            }
        }.resume()
    }
    
    /// Downloads images for the specified request, and then returns the downloaded image
    /// - Parameter completion: Provides downloaded image
    public func downloadImage(completion: @escaping (UIImage?) -> ()) {
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    completion(nil)
                    return
                }
                
                if let data = data {
                    guard let image = UIImage(data: data) else { return }
                    completion(image)
                }
            }
        }.resume()
    }
}
