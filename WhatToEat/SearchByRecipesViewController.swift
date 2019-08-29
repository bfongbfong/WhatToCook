//
//  SearchByRecipesViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest

class SearchByRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchByRecipesTableView: UITableView!
    
    var recipes: [Recipe] = []
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        searchByRecipesTableView.dataSource = self
        searchByRecipesTableView.delegate = self
        searchTextField.delegate = self
        
        searchByRecipesTableView.keyboardDismissMode = .onDrag
        
        searchTextField.contentVerticalAlignment = .center
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        navigationController?.navigationBar.barTintColor = myGreen
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "PoetsenOne-Regular", size: 21)!]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // i brought this code over from the saved recipes VC
        // because there are times when something that's supposed to be unsaved, still has a star in it.
        // specifically right after i unsave it from saved recipe VC and come back here to search by recipe vc.
        // but the WEIRD THING is that some of them do get unsaved! but some of them do stay saved...
//        if bookmarkedRecipeIDs.count > recipes.count {
//            if recipes.count != 0 {
//                let difference = bookmarkedRecipeIDs.count - recipes.count
//                for i in 0..<difference {
//                    getRecipeFromIntAndAddToSavedRecipesArray(id: bookmarkedRecipeIDs[savedRecipes.count + i])
//                }
//            } else {
//                if recipes.count == 0 {
//                    for recipeID in bookmarkedRecipeIDs {
//                        getRecipeFromIntAndAddToSavedRecipesArray(id: recipeID)
//                        print("SAVED RECIPE VC VIEW DID LOAD HAPPENED")
//                    }
//                }
//            }
//        } else if recipes.count > bookmarkedRecipeIDs.count {
//            recipes = savedRecipes.filter({bookmarkedRecipeIDs.contains($0.id!)})
//        }
        searchByRecipesTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
//        let attributes = [
//            NSAttributedString.Key.font : UIFont(name: "Gotham", size: 30)! // Note the !
//        ]
        
//        searchTextField.attributedPlaceholder = NSAttributedString(string: "SEARCH RECIPES", attributes:attributes)
        
        // to make "SEARCH INGREDIENTS" placeholder text fit and cetner vertically
        for subview in searchTextField.subviews {
            if let label = subview as? UILabel {
                label.minimumScaleFactor = 0.3
                label.adjustsFontSizeToFitWidth = true
                label.baselineAdjustment = .alignCenters
                label.textAlignment = .center
            }
        }
    
        
        // add horizontal padding to "SEARCH INGREDIENTS" placeholder
        let leftPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        let rightPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        searchTextField.leftView = leftPaddingView
        searchTextField.leftViewMode = .always
        searchTextField.rightView = rightPaddingView
        searchTextField.rightViewMode = .always
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = searchByRecipesTableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! SearchResultTableViewCell
//        cell.titleLabel.text = recipes[indexPath.row].title
        cell.selectionStyle = .none
        // this is because in the middle of the autocomplete API calls, sometimes when deleting there are small windows where the recipes array is being deleted but this method still runs erroneously.
        if indexPath.row >= recipes.count {
            cell.titleLabel.text = ""
            cell.ingredientsLabel.text = ""
            return cell
        }
        cell.updateCell(with: recipes[indexPath.row])
        return cell
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if searchTextField.text == "" || searchTextField.text == " " {
            recipes.removeAll()
            searchByRecipesTableView.reloadData()
        } else {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getAutocomplete), userInfo: nil, repeats: false)
        }
        return true
    }
    
    @objc func getAutocomplete() {

        if let text = searchTextField.text {
            getRecipes(numberOfResults: 15, input: text)
        }
        
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
//
        // this stuff i moved above
        if searchTextField.text == "" || searchTextField.text == " " {
            recipes.removeAll()
            searchByRecipesTableView.reloadData()
        }
//        } else {
//            if let text = searchTextField.text {
//                getRecipes(numberOfResults: 15, input: text)
//            }
//        }
    }
    
    func getRecipes(numberOfResults: Int, input: String) {
        
        if input == "" || input == " " {
            return
        }
        
        let inputAdjustedForSpecialCharacters = replaceSpecialCharacters(input: input)
        
        UNIRest.get { (request) in
            
            let requestString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/autocomplete?number=\(numberOfResults)&query=\(inputAdjustedForSpecialCharacters)"
            
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
            }
            }?.asJsonAsync({ (response, error) in
                
                let body: UNIJsonNode = response!.body
                
                if let errorThatHappened = error {
                    print("ERROR HAPPENED GOT DAMN IT")
                    print("btw this is the error: \(errorThatHappened)")
                }
                
                if let bodyJsonArray = body.jsonArray() {
                        print("JSON ARRAY ==================================================")
                        print(bodyJsonArray)
                    self.recipes.removeAll()
                    for jsonObject in bodyJsonArray {
                        if let dictionary = jsonObject as? [String: Any] {
                            let id = dictionary["id"] as? Int
                            let title = dictionary["title"] as? String
                            let recipe = Recipe()
                            recipe.id = id
                            recipe.title = title
                            self.getRecipeMoreData(recipe: recipe)
                        }
                    }
                }
//
//                DispatchQueue.main.async {
//                    self.searchByRecipesTableView.reloadData()
//                }
            })
    }
    
    func getRecipeMoreData(recipe: Recipe) {
        
        UNIRest.get { (request) in
            
            let requestString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/\(recipe.id!)/information"
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
            }
            
            }?.asJsonAsync({ (response, error) in
                let body: UNIJsonNode = response!.body
                
                if let bodyJsonObject = body.jsonObject() {
                    print("JSON OBJECT ==================================================")
                    print(bodyJsonObject)
                    
//                    recipe.source = bodyJsonObject["sourceUrl"] as? String
                    recipe.imageName = bodyJsonObject["image"] as? String
//                    recipe.servings = bodyJsonObject["servings"] as? Int
//                    recipe.readyInMinutes = bodyJsonObject["readyInMinutes"] as? Int
//                    recipe.diets = bodyJsonObject["diets"] as? [String]
//                    recipe.title = bodyJsonObject["title"] as? String
//                    recipe.creditsText = bodyJsonObject["creditsText"] as? String
                    
                    if let ingredientsArray = bodyJsonObject["extendedIngredients"] as? [[String:Any]] {
                        for ingredient in ingredientsArray {
                            let ingredientName = ingredient["name"] as? String
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
                }
                
                self.recipes.append(recipe)
                
                DispatchQueue.main.async {
                    self.searchByRecipesTableView.reloadData()
                }
            })
                
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromSearchByRecipesToRecipeDetailViewController" {
            if let selectedIndexPath = searchByRecipesTableView.indexPathForSelectedRow {
                let recipeDetailVC = segue.destination as! RecipeDetailViewController
                recipeDetailVC.recipe = recipes[selectedIndexPath.row]
            }
        }
    }
    

}

