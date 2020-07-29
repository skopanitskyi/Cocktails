//
//  CocktailsUrl.swift
//  Cocktails
//
//  Created by Копаницкий Сергей on 6/30/20.
//  Copyright © 2020 Копаницкий Сергей. All rights reserved.
//

import Foundation

/// Create request depending on the necessary data
enum CocktailRequest {
    
    // MARK: - Cocktails request cases
    
    /// Available cases for creating a request for downloading data
    case searchByName(name: String)
    case serchByCategory(category: String)
    case image(url: String)
    
    // MARK: - Cocktails request variables
    
    /// Returns the created request
    public var request: URLRequest? {
        let request: URLRequest?
        guard var components = URLComponents(string: baseUrl) else { return nil }
        
        switch self {
        case .searchByName:
            guard let path = path, let queryItem = queryItem else {
                return nil
            }
            components.path = path
            components.queryItems = [queryItem]
            guard let url = components.url else { return nil}
            request = URLRequest(url: url)
            
        case .serchByCategory:
            guard let path = path, let queryItem = queryItem else {
                return nil
            }
            components.path = path
            components.queryItems = [queryItem]
            guard let url = components.url else { return nil}
            request = URLRequest(url: url)
            
        case .image(let url):
            guard let url = URL(string: url) else { return nil }
            request = URLRequest(url: url)
        }
        return request
    }
    
    /// Returns a base url to get cocktail data
    private var baseUrl: String {
        return "https://www.thecocktaildb.com"
    }
    
    /// Returns the path depending on the downloaded data
    private var path: String? {
        switch self {
        case .searchByName:
            return "/api/json/v1/\(apiKey)/search.php"
        case .serchByCategory:
            return "/api/json/v1/\(apiKey)/filter.php"
        case .image:
            return nil
        }
    }
    /// Returns API key
    private var apiKey: String {
        return "1"
    }
    
    /// Returns query item
    private var queryItem: URLQueryItem? {
        switch self {
        case .searchByName(let value):
            return URLQueryItem(name: "s", value: value)
        case .serchByCategory(let value):
            return URLQueryItem(name: "c", value: value)
        case .image:
            return nil
        }
    }
}
