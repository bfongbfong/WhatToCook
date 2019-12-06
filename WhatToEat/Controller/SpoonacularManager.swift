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
    
    static var rapidAPIHost = "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    static var apiKey = "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"
    
    static func autocompleteIngredientSearch(input: String, completion: @escaping(_ responseJSON: [Any]?, _ error: Error?) -> Void) {
        
        let inputAdjustedForSpecialCharacters = replaceSpecialCharacters(input: input)
        
        UNIRest.get { (request) in
            
            let requestString = "https://\(rapidAPIHost)/food/ingredients/autocomplete?number=7&query=\(inputAdjustedForSpecialCharacters)"
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost, "X-RapidAPI-Key": apiKey]
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
                
                DispatchQueue.main.async {
                    completion(bodyJsonArray, error)
                }
            })
    }
    
    
    static func searchRecipesByIngredients(ingredients: String, numberOfResults: Int, ignorePantry: Bool, completion: @escaping(_ json: [Any]?, _ error: Error?) -> Void) {
        
        UNIRest.get { (request) in
            
            let requestString = "https://\(rapidAPIHost)/recipes/findByIngredients?number=\(numberOfResults)&ranking=1&ignorePantry=\(String(ignorePantry))&ingredients=\(ingredients)"
            
            print("==============================================================")
            print("RECIPES")
            
            guard let unwrappedRequest = request else { return }
            
            unwrappedRequest.url = requestString
            unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost, "X-RapidAPI-Key": apiKey]
            
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
    
    static func getRecipeInformation(recipeId: Int, completion: @escaping((_ response: [String: Any]?, _ error: Error?) -> Void)) {
        
        UNIRest.get { (request) in
                        
            let requestString = "https://\(rapidAPIHost)/recipes/\(recipeId)/information"
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost, "X-RapidAPI-Key": apiKey]
            }
            
            }?.asJsonAsync({ (response, error) in
                
                if let errorThatHappened = error {
                    completion(nil, errorThatHappened)
                    return
                }
                guard let responseReceived = response else {
                    completion(nil, error)
                    return
                }
                guard let body: UNIJsonNode = responseReceived.body else {
                    completion(nil, error)
                    return
                }
                guard let bodyJsonObject = body.jsonObject() as? [String: Any] else {
                    completion(nil, error)
                    return
                }
                completion(bodyJsonObject, error)
            })
    }
    
//    static func getRecipeFromIdAndAddToSavedRecipesArray(id: Int) {
//
//        let returnRecipe = Recipe()
//
//        UNIRest.get { (request) in
//
//            let requestString = "https://\(rapidAPIHost)recipes/\(id)/information"
//
//            if let unwrappedRequest = request {
//                unwrappedRequest.url = requestString
//                unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
//            }
//
//            }?.asJsonAsync({ (response, error) in
//
//                if let response = response {
//                    if let body: UNIJsonNode = response.body {
//                        if let bodyJsonObject = body.jsonObject() {
//                            print("JSON OBJECT ==================================================")
//                            print(bodyJsonObject)
//
//                            returnRecipe.source = bodyJsonObject["sourceUrl"] as? String
//                            returnRecipe.imageName = bodyJsonObject["image"] as? String
//                            returnRecipe.servings = bodyJsonObject["servings"] as? Int
//                            returnRecipe.readyInMinutes = bodyJsonObject["readyInMinutes"] as? Int
//                            returnRecipe.diets = bodyJsonObject["diets"] as? [String]
//                            returnRecipe.title = bodyJsonObject["title"] as? String
//                            returnRecipe.creditsText = bodyJsonObject["creditsText"] as? String
//
//                            if let ingredientsArray = bodyJsonObject["extendedIngredients"] as? [[String:Any]] {
//                                for ingredient in ingredientsArray {
//                                    let ingredientName = ingredient["name"] as? String
//                                    let ingredientAmount = ingredient["amount"] as? Int
//                                    let ingredientAisle = ingredient["aisle"] as? String
//                                    let ingredientUnit = ingredient["unit"] as? String
//                                    let ingredientId = ingredient["id"] as? Int
//                                    let ingredientImage = ingredient["image"] as? String
//                                    var ingredientUnitShort: String?
//
//                                    if let measures = ingredient["measures"] as? [String: Any] {
//                                        if let us = measures["us"] as? [String: Any] {
//                                            ingredientUnitShort = us["unitShort"] as? String
//                                        }
//                                    }
//
//                                    let newIngredient = Ingredient(aisle: ingredientAisle, amount: ingredientAmount as NSNumber?, id: ingredientId, imageName: ingredientImage, name: ingredientName, unit: ingredientUnit, unitShort: ingredientUnitShort)
//                                    returnRecipe.ingredients.append(newIngredient)
//                                }
//                            }
//                            returnRecipe.id = id
//                            self.savedRecipes.append(returnRecipe)
//                        }
//
//                        DispatchQueue.main.async {
//                            if self.savedRecipes.count > 1 && PersistenceManager.bookmarkedRecipeIDs.count == self.savedRecipes.count {
//                                self.reorderSavedRecipesArray()
//                            }
//                            self.savedRecipesTableView.reloadData()
//                        }
//                    }
//                }
//            })
//    }
}
