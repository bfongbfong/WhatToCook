//
//  JsonParser.swift
//  WhatToEat
//
//  Created by Brandon Fong on 12/8/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class JsonParser {
    
    static func parseJsonToIngredient(jsonObject: [String: Any]) -> Ingredient? {
        
        let ingredientName = jsonObject["name"] as? String
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
        for jsonObject in jsonArray {
            guard let jsonObject = jsonObject as? [String: Any] else { continue }
            guard let ingredient = parseJsonToIngredient(jsonObject: jsonObject) else { continue }
            returnArrayOfIngredients.append(ingredient)
        }
        return returnArrayOfIngredients
    }
    
}
