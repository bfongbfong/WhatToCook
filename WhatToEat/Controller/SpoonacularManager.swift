//
//  SpoonacularManager.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation
import Unirest

class SpoonacularManager {
    
    static func autocompleteIngredientSearch(input: String, completion: @escaping(_ responseJSON: [Any]?, _ error: Error?) -> Void) {
        
        if input == "" || input == " " {
            return
        }
        
        let inputAdjustedForSpecialCharacters = replaceSpecialCharacters(input: input)
        
        UNIRest.get { (request) in
            
            let requestString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/autocomplete?number=7&query=\(inputAdjustedForSpecialCharacters)"
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
            }
            
            }?.asJsonAsync({ (response, error) in
                
                if let errorThatHappened = error {
                    completion(nil, errorThatHappened);
                    return
                }
                
                guard let response = response else {
                    completion(nil, error);
                    return
                }
                
                guard let body: UNIJsonNode = response.body else {
                    completion(nil, error);
                    return
                }
                
                guard let bodyJsonArray = body.jsonArray() else {
                    completion(nil, error);
                    return
                }
                
                completion(bodyJsonArray, error)
            })
    }
    
    
    static func searchRecipesByIngredients(ingredients: String, numberOfResults: Int, ignorePantry: Bool, completion: @escaping(_ json: [Any]?, _ error: Error?) -> Void) {
        
        UNIRest.get { (request) in
            
            let requestString: String = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/findByIngredients?number=\(numberOfResults)&ranking=1&ignorePantry=\(String(ignorePantry))&ingredients=\(ingredients)"
            
            print(requestString)
            print("==============================================================")
            print("RECIPES")
            
            guard let unwrappedRequest = request else { return }
            
            unwrappedRequest.url = requestString
            unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
            
            }?.asJsonAsync({ (response, error) in
                
                if let errorThatHappened = error {
                    completion(nil, errorThatHappened)
                    return
                }
                
                guard let response = response else {
                    completion(nil, error)
                    return
                }
                
                guard let body: UNIJsonNode = response.body else {
                    completion(nil, error)
                    return
                }
                
                guard let bodyJsonArray = body.jsonArray() else {
                    completion(nil, error)
                    return
                }
                
                completion(bodyJsonArray, error)
            })
    }
}
