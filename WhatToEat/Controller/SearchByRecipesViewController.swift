//
//  SearchByRecipesViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest
import GoogleMobileAds

class SearchByRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, GADBannerViewDelegate, GADInterstitialDelegate {

    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchByRecipesTableView: UITableView!
    
    // MARK: - Properties
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var recipes: [Recipe] = []
    var timer: Timer?
    
    // MARK: - View Controller Life Cycle
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
        navigationController?.navigationBar.barTintColor = UIColor.myGreen
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "PoetsenOne-Regular", size: 21)!]
        
        // ads
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        // real id
        bannerView.adUnitID = adIDs.searchByRecipeNameVCBannerID
        // test id
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchByRecipesTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
}

extension SearchByRecipesViewController {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Add banner to view and add constraints as above.
        addBannerViewToView(bannerView)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {

        let interstitial = GADInterstitial(adUnitID: adIDs.beforeInterstitialID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
}

extension SearchByRecipesViewController {
    
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
        guard let text = searchTextField.text else {
            print("textfield.text was nil")
            return
        }
        
        guard let firstLetter = Array(text).first else {
            return
        }

        guard text != "" && firstLetter != " " else {
            return
        }
            
        getRecipes(numberOfResults: 15, input: text)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {

        if searchTextField.text == "" || searchTextField.text == " " {
            recipes.removeAll()
            searchByRecipesTableView.reloadData()
        }
    }
}

extension SearchByRecipesViewController {
    
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
                    print("error: \(errorThatHappened)")
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
                guard recipes.count > 0 else { return }
                recipeDetailVC.recipe = recipes[selectedIndexPath.row]
                if interstitial.isReady && RecipesViewed.isMultipleOfThree {
                    interstitial.present(fromRootViewController: self)
                }
            }
        }
    }
    

}

