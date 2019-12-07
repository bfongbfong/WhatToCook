//
//  CoreDataManager.swift
//  WhatToEat
//
//  Created by Brandon Fong on 12/6/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static var context = persistentContainer.viewContext
    
    static var persistentContainer: NSPersistentContainer = {
       /*
        The persistent container for the application. This implementation
        creates and returns a container, having loaded the store for the
        application to it. This property is optional since there are legitimate
        error conditions that could cause the creation of the store to fail.
       */
       let container = NSPersistentContainer(name: "WhatToEat")
       container.loadPersistentStores(completionHandler: { (storeDescription, error) in
           if let error = error as NSError? {
               // Replace this implementation with code to handle the error appropriately.
               // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
               /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
               fatalError("Unresolved error \(error), \(error.userInfo)")
           }
       })
       return container
    }()

   // MARK: - Core Data Saving support

   static func saveContext () {
       if context.hasChanges {
           do {
               try context.save()
           } catch {
               // Replace this implementation with code to handle the error appropriately.
               // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               let nserror = error as NSError
               fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           }
       }
   }
    
    static func convertToCDType(recipe: Recipe) -> CDRecipe {
        let newRecipe = CDRecipe(context: context)
        newRecipe.title = recipe.title
        newRecipe.id = Int64(recipe.id!)
        newRecipe.imageName = recipe.imageName
        newRecipe.imageData = recipe.imageData
        newRecipe.url = recipe.url
        newRecipe.source = recipe.source
        newRecipe.readyInMinutes = Int64(recipe.readyInMinutes!)
        newRecipe.servings = Int64(recipe.servings!)
        newRecipe.diets = recipe.diets as NSObject?
        newRecipe.creditsText = recipe.creditsText
        newRecipe.bookmarked = recipe.bookmarked
        
        var cdIngredientArray = [CDIngredient]()
        for ingredient in recipe.ingredients {
            let newIngredient = convertToCDType(ingredient: ingredient)
            cdIngredientArray.append(newIngredient)
        }
        
        newRecipe.ingredients = NSSet(object: cdIngredientArray)
        
        return newRecipe
    }
    
    static func convertToCDType(ingredient: Ingredient) -> CDIngredient {
        let newIngredient = CDIngredient(context: context)
        newIngredient.aisle = ingredient.aisle
        newIngredient.amount = Int64(ingredient.amount!)
        newIngredient.id = Int64(ingredient.id!)
        newIngredient.imageName = ingredient.imageName
        newIngredient.name = ingredient.name
        newIngredient.unit = ingredient.unit
        newIngredient.unitShort = ingredient.unitShort
        return newIngredient
    }
}
