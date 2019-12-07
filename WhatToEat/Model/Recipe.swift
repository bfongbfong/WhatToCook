//
//  Recipe.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/16/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation
import Unirest

class Recipe: Equatable {
    
    var title: String?
    var id: Int?
    var imageName: String?
    var image: UIImage?
    var usedIngredients: [Ingredient] = []
    
    // properties to be used at recipe detail
    var url: URL?
    var ingredients: [Ingredient] = []
    var instructions: [[String]] = [[]]
    var source: String?
    var readyInMinutes: Int?
    var servings: Int?
    var diets: [String]?
    var creditsText: String?
    var bookmarked: Bool = false {
        didSet {
            if bookmarked == true {
                // this next part is to prevent copies of the recipe to be saved
                // if bookmarkedRecipeIDs is empty, append.
                if PersistenceManager.bookmarkedRecipeIDs.count == 0 {
                    PersistenceManager.bookmarkedRecipeIDs.append(self.id!)
                } else {
                    if !PersistenceManager.bookmarkedRecipeIDs.contains(self.id!) {
                        PersistenceManager.bookmarkedRecipeIDs.append(self.id!)
                    }
                }
            } else {
                // removes bookmarked recipe from bookmarkedRecipeIDs
                let arrayWithoutTargetRecipe = PersistenceManager.bookmarkedRecipeIDs.filter { $0 != self.id }
                PersistenceManager.bookmarkedRecipeIDs = arrayWithoutTargetRecipe
            }
        }
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}

