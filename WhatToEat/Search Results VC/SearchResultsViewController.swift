//
//  SearchResultsViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/17/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchResultDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ingredientNames: String = ""
    var recipes: [Recipe] = []
    
    var loadingView: UIView!
    let activityIndicatoryView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getRecipes(ingredients: ingredientNames, numberOfResults: 30, ignorePantry: true)
        
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        loadingView.backgroundColor = .white
        self.view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        
        activityIndicatoryView.style = .gray
        activityIndicatoryView.center = CGPoint(x: view.center.x, y: view.center.y)
        activityIndicatoryView.startAnimating()
        loadingView.addSubview(activityIndicatoryView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! SearchResultTableViewCell
        cell.updateCellWithUsedIngredients(with: recipes[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    
    func getRecipes(ingredients: String, numberOfResults: Int, ignorePantry: Bool) {
        UNIRest.get { (request) in
            
            let requestString: String = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/findByIngredients?number=\(numberOfResults)&ranking=1&ignorePantry=\(String(ignorePantry))&ingredients=\(ingredients)"
            
            print(requestString)
            print("==============================================================")
            print("RECIPES")
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
            }
            
            }?.asJsonAsync({ (response, error) in
                
                if let response = response {
                    if let body: UNIJsonNode = response.body {
                        if let bodyJsonArray = body.jsonArray() {
                            print("JSON ARRAY ==================================================")
                            print(bodyJsonArray)
                            for json in bodyJsonArray {
                                let recipe = Recipe()
                                if let dictionary = json as? [String : Any] {
                                    recipe.id = dictionary["id"] as? Int
                                    recipe.imageName = dictionary["image"] as? String
                                    recipe.missedIngredientCount = dictionary["missedIngredientCount"] as? Int
                                    recipe.usedIngredientCount = dictionary["usedIngredientCount"] as? Int
                                    recipe.unusedIngredientCount = dictionary["unusedIngredientCount"] as? Int
                                    recipe.title = dictionary["title"] as? String
                                    if let missedIngredientsArray = dictionary["missedIngredients"] as? [[String : Any]]  {
                                        for i in 0..<missedIngredientsArray.count {
                                            
                                            let ingredient = Ingredient(
                                                aisle: missedIngredientsArray[i]["aisle"] as? String ?? "",
                                                amount: missedIngredientsArray[i]["amount"] as! NSNumber,
                                                id: missedIngredientsArray[i]["id"] as! Int,
                                                imageName: missedIngredientsArray[i]["imageName"] as? String ?? "no image name",
                                                name: missedIngredientsArray[i]["name"] as! String,
                                                originalString: missedIngredientsArray[i]["originalString"] as! String,
                                                unit: missedIngredientsArray[i]["unit"] as! String,
                                                unitShort: missedIngredientsArray[i]["unitShort"] as! String)
                                            //                                    print("adding missing ingredient called \(ingredient.name)")
                                            
                                            recipe.missedIngredients.append(ingredient)
                                            //                                    print("missed ingredient just added called: \(recipe.missedIngredients[i].name)")
                                        }
                                    }
                                    if let unusedIngredientsArray = dictionary["unusedIngredients"] as? [[String: Any]] {
                                        for i in 0..<unusedIngredientsArray.count {
                                            
                                            let ingredient = Ingredient(
                                                aisle: unusedIngredientsArray[i]["aisle"] as? String ?? "",
                                                amount: unusedIngredientsArray[i]["amount"] as! NSNumber,
                                                id: unusedIngredientsArray[i]["id"] as! Int,
                                                imageName: unusedIngredientsArray[i]["imageName"] as? String ?? "no image name",
                                                name: unusedIngredientsArray[i]["name"] as! String,
                                                originalString: unusedIngredientsArray[i]["originalString"] as! String,
                                                unit: unusedIngredientsArray[i]["unit"] as! String,
                                                unitShort: unusedIngredientsArray[i]["unitShort"] as! String)
                                            
                                            
                                            recipe.unusedIngredients.append(ingredient)
                                        }
                                    }
                                    if let usedIngredientsArray = dictionary["usedIngredients"] as? [[String: Any]] {
                                        for i in 0..<usedIngredientsArray.count {
                                            
                                            let ingredient = Ingredient(
                                                aisle: usedIngredientsArray[i]["aisle"] as! String,
                                                amount: usedIngredientsArray[i]["amount"] as! NSNumber,
                                                id: usedIngredientsArray[i]["id"] as! Int,
                                                imageName: usedIngredientsArray[i]["imageName"] as? String ?? "no image name",
                                                name: usedIngredientsArray[i]["name"] as! String,
                                                originalString: usedIngredientsArray[i]["originalString"] as! String,
                                                unit: usedIngredientsArray[i]["unit"] as! String,
                                                unitShort: usedIngredientsArray[i]["unitShort"] as! String)
                                            
                                            //                                    print("adding used ingredient called \(ingredient.name)")
                                            recipe.usedIngredients.append(ingredient)
                                            //                                    print("used ingredient just added called: \(recipe.usedIngredients[i].name)")
                                        }
                                    }
                                }
                                self.recipes.append(recipe)
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            })
    }
    
    func loadingFinished() {
        self.loadingView.removeFromSuperview()
        self.activityIndicatoryView.stopAnimating()
        self.activityIndicatoryView.removeFromSuperview()
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToRecipeDetailViewController" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let recipeDetailVC = segue.destination as! RecipeDetailViewController
                recipeDetailVC.recipe = recipes[selectedIndexPath.row]
                print("PREAPRE FOR SEGUE HAPPENED ")
            }
        }
        
     }
 


}
