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
    var missedIngredientCount: Int?
    var missedIngredients: [Ingredient] = []
    var unusedIngredients: [Ingredient] = []
    var unusedIngredientCount: Int?
    var usedIngredientCount: Int?
    var usedIngredients: [Ingredient] = []
    
    // properties to be used at recipe detail
    var url: URL?
    var summary: String?
    var ingredients: [Ingredient] = []
    var instructions: [[String]] = [[]]
    var source: String?
    var readyInMinutes: Int?
    var servings: Int?
    var diets: [String]?
    var creditsText: String?
    var bookmarked: Bool = false {
        didSet {
            print("bookmarked did set called")
            if bookmarked == true {
                print("bookmarked was true")
                // this next part is to prevent copies of the recipe to be saved
                
                // A FOR IN LOOP DOESN'T GET CALLED IF THE ARRAY IS EMPTY DUMMYYY
                if bookmarkedRecipeIDs.count == 0 {
                    bookmarkedRecipeIDs.append(self.id!)
                } else {
                    // there error is that you are looping through everything in bookmarkedRecipeIDs and comparing every item to the newest item. if the item isn't the same, then you are adding it. but what if you're comparing something that has a match SOMEHERE in the array... you still add it to the array!
                    // that's not right.
                    // it should be: compare every value in your array with your target value. if you finish the entire array and it doesn't find a match, then append it. if not, return.
//                    for bookmarkedRecipeID in bookmarkedRecipeIDs {
//                        if bookmarkedRecipeID == self.id {
//                            return
//                        } else {
//                            bookmarkedRecipeIDs.append(self.id!)
//                        }
//                    }
                    
                    if !loopThrough(id: self.id!) {
                        bookmarkedRecipeIDs.append(self.id!)
                    }
                }
                
                

            } else {
                print("bookmarked was set to false")
                let arrayWithoutTargetRecipe = bookmarkedRecipeIDs.filter {$0 != self.id}
                bookmarkedRecipeIDs = arrayWithoutTargetRecipe
            }
            
            // print bookmarked recipes
//            let bookmarkedRecipesToPrint = bookmarkedRecipeIDs.map { (recipe) -> Int in
//                return recipe.id!
//            }
//            print(bookmarkedRecipesToPrint)
            

            for recipeID in bookmarkedRecipeIDs {
                print(recipeID)
            }
        }
    }
    // this was an idea i had to help keep local recipe arrays to be the same as bookmarkedRecipeIds but im not sure it's a good idea anymore
    var orderInArray: Int?
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}

private func loopThrough(id: Int) -> Bool {
    
    for bookmarkedRecipeID in bookmarkedRecipeIDs {
        if bookmarkedRecipeID == id {
            return true
        }
    }
    return false
}


struct Ingredient {
    var aisle: String?
    var amount: NSNumber?
    var id: Int?
    var imageName: String?
    var name: String?
    var originalString: String?
    var unit: String?
    var unitShort: String?
    
    init(aisle: String, amount: NSNumber, id: Int, imageName: String, name: String, originalString: String, unit: String, unitShort: String) {
        self.aisle = aisle
        self.amount = amount
        self.id = id
        self.imageName = imageName
        self.name = name
        self.originalString = originalString
        self.unit = unit
        self.unitShort = unitShort
    }
    
    init(aisle: String?, amount: NSNumber?, id: Int?, imageName: String?, name: String?, unit: String?, unitShort: String?) {
        self.aisle = aisle
        self.amount = amount
        self.id = id
        self.imageName = imageName
        self.name = name
        self.originalString = nil
        self.unit = unit
        self.unitShort = unitShort
    }
    
    init(name: String, amount: NSNumber, id: Int, imageName: String, unitShort: String) {
        self.name = name
        self.amount = amount
        self.id = id
        self.imageName = imageName
        self.unitShort = unitShort
        self.aisle = ""
    }
}

struct SearchedIngredient: Equatable {

    var name: String
    var imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
    
    static func == (lhs: SearchedIngredient, rhs: SearchedIngredient) -> Bool {
        return lhs.name == rhs.name
    }
}


//var bookmarkedRecipes: [Recipe] = []
//{
//    didSet {
//        bookmarkedRecipeIDs = bookmarkedRecipes.map({ (recipe) -> Int in
//            return recipe.id!
//        })
//    }
//}

// make bookmarkedRecipeIDs a computed property or make a didSet on bookmarkedRecipes?
var bookmarkedRecipeIDs: [Int] = []
//{
//    get {
//        return bookmarkedRecipes.map({ (recipe) -> Int in
//            return recipe.id!
//        })
//    }
//}


func loadBookmarkedRecipes() {
    guard let retrievedData = UserDefaults.standard.array(forKey: "BookmarkedRecipeIDs") else { return }

    bookmarkedRecipeIDs.removeAll()

    bookmarkedRecipeIDs = retrievedData as! [Int]
    print("RETRIEVED BOOKMARKED RECIPE IDS: \(bookmarkedRecipeIDs)")
}

func saveBookmarkedRecipes() {
    UserDefaults.standard.set(bookmarkedRecipeIDs, forKey: "BookmarkedRecipeIDs")
    print("BOOKMARKED IDS SAVED")
}

func getRecipeInstructions(recipeID: Int) {
//
//    var returnRecipe = Recipe()
//
//    UNIRest.get { (request) in
//
//        let requestString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/\(recipeID)/information"
//
//        if let unwrappedRequest = request {
//            unwrappedRequest.url = requestString
//            unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
//        }
//
//        }?.asJsonAsync({ (response, error) in
//
//            let body: UNIJsonNode = response!.body
//            //                let rawBody: Data = response!.rawBody
//            //                print(String(data: rawBody, encoding: .utf8))
//
//            if let bodyJsonArray = body.jsonArray() {
//                print("JSON ARRAY RECIPE INSTRUCTIONS ==================================================")
//                print(bodyJsonArray)
//            }
//
//            if let bodyJsonObject = body.jsonObject() {
//                print("JSON OBJECT ==================================================")
//                print(bodyJsonObject)
//
//                returnRecipe.source = bodyJsonObject["sourceUrl"] as? String
//                self.recipe.servings = bodyJsonObject["servings"] as? Int
//                self.recipe.readyInMinutes = bodyJsonObject["readyInMinutes"] as? Int
//                self.recipe.diets = bodyJsonObject["diets"] as? [String]
//                self.recipe.title = bodyJsonObject["title"] as? String
//                self.recipe.creditsText = bodyJsonObject["creditsText"] as? String
//
//                if let ingredientsArray = bodyJsonObject["extendedIngredients"] as? [[String:Any]] {
//                    for ingredient in ingredientsArray {
//                        let ingredientName = ingredient["name"] as? String
//                        let ingredientAmount = ingredient["amount"] as? Int
//                        let ingredientAisle = ingredient["aisle"] as? String
//                        let ingredientUnit = ingredient["unit"] as? String
//                        let ingredientId = ingredient["id"] as? Int
//                        let ingredientImage = ingredient["image"] as? String
//                        var ingredientUnitShort: String?
//
//                        if let measures = ingredient["measures"] as? [String: Any] {
//                            if let us = measures["us"] as? [String: Any] {
//                                ingredientUnitShort = us["unitShort"] as? String
//                            }
//                        }
//
//                        let newIngredient = Ingredient(aisle: ingredientAisle, amount: ingredientAmount as NSNumber?, id: ingredientId, imageName: ingredientImage, name: ingredientName, unit: ingredientUnit, unitShort: ingredientUnitShort)
//                        self.recipe.ingredients.append(newIngredient)
//                    }
//                }
//
//
//
//                let analyzedInstructions = bodyJsonObject["analyzedInstructions"] as! [NSDictionary]
//                for (index, section) in analyzedInstructions.enumerated() {
//                    if let sectionName = section["name"] as? String {
//                        self.instructions.append([sectionName])
//                        if let sectionInstructions = section["steps"] as? [ [String : Any] ] {
//                            for instructionInfo in sectionInstructions {
//                                if let singleStep = instructionInfo["step"] as? String {
//                                    self.instructions[index].append(singleStep)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//    })
}


