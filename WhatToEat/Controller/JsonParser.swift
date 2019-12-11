//
//  JsonParser.swift
//  WhatToEat
//
//  Created by Brandon Fong on 12/8/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class JsonParser {
    
    /// Parses a JSON object from Spoonacular API for a regular Ingredient into the Ingredient data model.
    ///
    /// - Parameters:
    ///     - jsonObject: JSON object from Spoonacular API for a regular ingredient.
    ///     - alreadyParsedIngredients: An optional set of ingredient names passed on from wherever the method was called. Used for elimintating duplicate ingredients.
    /// - Returns: An optional ingredient.
    static func parseJsonToIngredient(jsonObject: [String: Any], alreadyParsedIngredientNames: inout Set<String>) -> Ingredient? {
        
        let ingredientName = jsonObject["name"] as? String

        guard ingredientName != nil else { return nil }
            
        if alreadyParsedIngredientNames.contains(ingredientName!) {
            return nil
        }
        
        alreadyParsedIngredientNames.insert(ingredientName!)
        
        let ingredientAmount = jsonObject["amount"] as? Int
        let ingredientAisle = jsonObject["aisle"] as? String
        let ingredientUnit = jsonObject["unit"] as? String
        let ingredientId = jsonObject["id"] as? Int
        let ingredientImage = jsonObject["image"] as? String
        var ingredientUnitShort: String?
        
        if let measures = jsonObject["measures"] as? [String: Any] {
            if let us = measures["us"] as? [String: Any] {
                ingredientUnitShort = us["unitShort"] as? String
            }
        }
        
        let newIngredient = Ingredient(aisle: ingredientAisle, amount: ingredientAmount as NSNumber?, id: ingredientId, imageName: ingredientImage, name: ingredientName, unit: ingredientUnit, unitShort: ingredientUnitShort)
        return newIngredient
    }
    
    static func parseJsonToIngredientsArray(jsonArray: [Any]) -> [Ingredient]? {
        var returnArrayOfIngredients = [Ingredient]()
        var alreadyParsedIngredientNames: Set<String> = []
        // make this part function like in the method below, weeding out duplicates.
        
        for jsonObject in jsonArray {
            guard let jsonObject = jsonObject as? [String: Any] else { continue }
            guard let ingredient = parseJsonToIngredient(jsonObject: jsonObject, alreadyParsedIngredientNames: &alreadyParsedIngredientNames) else { continue }
            returnArrayOfIngredients.append(ingredient)
        }
        return returnArrayOfIngredients
    }
    
    static func parseJsonForInfo(json: [String: Any]?, recipe: inout Recipe) {
        
        guard let bodyJsonObject = json else { return }
        
        recipe.source = bodyJsonObject["sourceUrl"] as? String
        recipe.servings = bodyJsonObject["servings"] as? Int
        recipe.readyInMinutes = bodyJsonObject["readyInMinutes"] as? Int
        recipe.diets = bodyJsonObject["diets"] as? [String]
        recipe.title = bodyJsonObject["title"] as? String
        recipe.creditsText = bodyJsonObject["creditsText"] as? String
        
        if let ingredientsArray = bodyJsonObject["extendedIngredients"] as? [[String:Any]] {
            // so ingredients don't get repeat added
            recipe.ingredients.removeAll()
            var ingredientNames: Set<String> = []
            for ingredient in ingredientsArray {
                let ingredientName = ingredient["name"] as? String
                if ingredientName != nil && ingredientNames.contains(ingredientName!) {
                    continue
                } else {
                    ingredientNames.insert(ingredientName!)
                }
                let ingredientAmount = ingredient["amount"] as? Int
                let ingredientAisle = ingredient["aisle"] as? String
                let ingredientUnit = ingredient["unit"] as? String
                let ingredientId = ingredient["id"] as? Int
                let ingredientImage = ingredient["image"] as? String
                var ingredientUnitShort: String?
                
                if let measures = ingredient["measures"] as? [String: Any] {
                    if let us = measures["us"] as? [String: Any] {
                        ingredientUnitShort = us["unitShort"] as? String
                    }
                }
                
                let newIngredient = Ingredient(aisle: ingredientAisle, amount: ingredientAmount as NSNumber?, id: ingredientId, imageName: ingredientImage, name: ingredientName, unit: ingredientUnit, unitShort: ingredientUnitShort)
                recipe.ingredients.append(newIngredient)
            }
        }
        
        let analyzedInstructions = bodyJsonObject["analyzedInstructions"] as! [NSDictionary]
        // so instructions don't get repeat added
        recipe.instructions.removeAll()
        for (index, section) in analyzedInstructions.enumerated() {
            if let sectionName = section["name"] as? String {
                recipe.instructions.append([sectionName])
                if let sectionInstructions = section["steps"] as? [ [String : Any] ] {
                    for instructionInfo in sectionInstructions {
                        if let singleStep = instructionInfo["step"] as? String {
                            recipe.instructions[index].append(singleStep)
                        }
                    }
                }
            }
        }
    }
    
}
