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
            
            let requestString = "https://\(rapidAPIHost)/food/ingredients/autocomplete/"
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost,
                                            "X-RapidAPI-Key": apiKey]
                unwrappedRequest.parameters = ["number": "7", "query": inputAdjustedForSpecialCharacters]
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
            
//            let requestString = "https://\(rapidAPIHost)/recipes/findByIngredients/"
            let requestString = "https://\(rapidAPIHost)/recipes/findByIngredients?number=\(numberOfResults)&ranking=2&ignorePantry=\(String(ignorePantry))&ingredients=\(ingredients)"

            
            print("==============================================================")
            print("RECIPES")
            
            guard let unwrappedRequest = request else { return }
            
            unwrappedRequest.url = requestString
            unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost,
                                        "X-RapidAPI-Key": apiKey]
            // Ranking: Whether to maximize used ingredients (1) or minimize missing ingredients (2) first.
//            unwrappedRequest.parameters = ["number": "\(numberOfResults)",
//                                           "ranking": "2",
//                                           "ignorePantry": String(ignorePantry),
//                                           "ingredients": ingredients]
            
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
    
    static func autocompleteRecipeSearch(input: String, numberOfResults: Int, completion: @escaping((_ jsonArray: [Any]?) -> Void)) {
        
        let inputAdjustedForSpecialCharacters = replaceSpecialCharacters(input: input)
        
        UNIRest.get { (request) in
            
            let requestString = "https://\(rapidAPIHost)/recipes/autocomplete?number=\(numberOfResults)&query=\(inputAdjustedForSpecialCharacters)"
            
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost,
                                            "X-RapidAPI-Key": apiKey]
            }
            
            }?.asJsonAsync({ (response, error) in
                if let errorThatHappened = error {
                    print(errorThatHappened.localizedDescription)
                    return
                }
                guard let response = response else {
                    completion(nil)
                    return
                }
                
                guard let body: UNIJsonNode = response.body else {
                    completion(nil)
                    return
                }
                
                guard let bodyJsonArray = body.jsonArray() else {
                    completion(nil)
                    return
                }
                
                completion(bodyJsonArray)
            })
    }
    
    static func getRecipeInformation(recipeId: Int, completion: @escaping((_ response: [String: Any]?, _ error: Error?) -> Void)) {
        
        UNIRest.get { (request) in
                        
            let requestString = "https://\(rapidAPIHost)/recipes/\(recipeId)/information"
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost,
                                            "X-RapidAPI-Key": apiKey]
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
    
    static func searchRecipes() {
        UNIRest.get { (request) in
            let requestString = ""
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": rapidAPIHost,
                                            "X-RapidAPI-Key": apiKey]
//                unwrappedRequest.parameters = []
                
            }
            
            }?.asJsonAsync({ (response, error) in
        })
    }
}
