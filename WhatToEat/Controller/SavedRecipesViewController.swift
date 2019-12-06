//
//  SavedRecipesViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/25/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest
import GoogleMobileAds

class SavedRecipesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var savedRecipesTableView: UITableView!
    
    // MARK: - Properties
    var savedRecipes: [Recipe] = []
    
    // reason for these recently deleted things is to maintain the state of the UI after an element is deleted from the VC, until you come back to it later, then it's gone.
    var recipeRecentlyDeleted = false {
        didSet {
            if recipeRecentlyDeleted == true {
                oldRecipesIncludedDeletedOnes = savedRecipes
            }
        }
    }
    var oldRecipesIncludedDeletedOnes: [Recipe] = []
    
    // Admob
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        savedRecipesTableView.delegate = self
        savedRecipesTableView.dataSource = self
        
        // ads
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        // test id
//      bannerView.adUnitID = "ca-app-pub-5775764210542302/4339264751"
        bannerView.adUnitID = adIDs.savedRecipesVCBannerID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interstitial = createAndLoadInterstitial()
        
        recipeRecentlyDeleted = false
        
        print("SAVED RECIPE VC VIEW WILL APPEAR HAPPENED")
        // if the API request isn't here, the tableView reload should be
        
        
        // to save new items from bookmarkedRecipeIDs to savedRecipes without adding duplicates
        if PersistenceManager.bookmarkedRecipeIDs.count > savedRecipes.count {
            
            if savedRecipes.count != 0 {
                let difference = PersistenceManager.bookmarkedRecipeIDs.count - savedRecipes.count
                for i in 0..<difference {
                    populateRecipeData(id: PersistenceManager.bookmarkedRecipeIDs[savedRecipes.count + i])
                }

            } else {
                if savedRecipes.count == 0 {
                    
                    for recipeID in PersistenceManager.bookmarkedRecipeIDs {
                        populateRecipeData(id: recipeID)
                        print("SAVED RECIPE VC VIEW DID LOAD HAPPENED")
                    }
                }
            }
        } else if savedRecipes.count > PersistenceManager.bookmarkedRecipeIDs.count {
            savedRecipes = savedRecipes.filter({PersistenceManager.bookmarkedRecipeIDs.contains($0.id!)})
            savedRecipesTableView.reloadData()
        }
        
        savedRecipesTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
}

// MARK: - IBActions and Objc Functions
extension SavedRecipesViewController {
    @objc func bookmarkButtonTapped(sender: UIButton) {
        recipeRecentlyDeleted = true
        PersistenceManager.bookmarkedRecipeIDs.remove(at: sender.tag)
        savedRecipes.remove(at: sender.tag)
        sender.isHidden = true
        savedRecipesTableView.reloadData()
    }
}

// MARK: - UI Functions
extension SavedRecipesViewController {
    
    func setUpNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.myGreen
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "PoetsenOne-Regular", size: 21)!]
    }
}

// MARK: - Logic Functions
extension SavedRecipesViewController {
    func reorderSavedRecipesArray() {
        var tempArray: [Recipe] = []
        
        for recipeID in PersistenceManager.bookmarkedRecipeIDs {
            for recipe in savedRecipes {
                if recipeID == recipe.id! {
                    tempArray.append(recipe)
                }
            }
        }
        
        savedRecipes = tempArray
        // needed to do all this to ensure that the arrays were in the same order.
    }
    
    func populateRecipeData(id: Int) {
        SpoonacularManager.getRecipeInformation(recipeId: id) { (json, error) in
            if let errorThatHappened = error {
                print(errorThatHappened.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.parseJson(json: json, id: id)
                
                if self.savedRecipes.count > 1 && PersistenceManager.bookmarkedRecipeIDs.count == self.savedRecipes.count {
                    self.reorderSavedRecipesArray()
                }
                self.savedRecipesTableView.reloadData()
            }
        }
    }
    
    private func parseJson(json: [String: Any]?, id: Int) {
        
        let returnRecipe = Recipe()
        
        if let bodyJsonObject = json {
            print("JSON OBJECT ==================================================")
            print(bodyJsonObject)
            
            returnRecipe.source = bodyJsonObject["sourceUrl"] as? String
            returnRecipe.imageName = bodyJsonObject["image"] as? String
            returnRecipe.servings = bodyJsonObject["servings"] as? Int
            returnRecipe.readyInMinutes = bodyJsonObject["readyInMinutes"] as? Int
            returnRecipe.diets = bodyJsonObject["diets"] as? [String]
            returnRecipe.title = bodyJsonObject["title"] as? String
            returnRecipe.creditsText = bodyJsonObject["creditsText"] as? String
            
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
                    returnRecipe.ingredients.append(newIngredient)
                }
            }
            returnRecipe.id = id
            self.savedRecipes.append(returnRecipe)
        }
    }
}


// MARK: - UITableView
extension SavedRecipesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recipeRecentlyDeleted == true {
            return oldRecipesIncludedDeletedOnes.count
        }
        return savedRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedRecipesTableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! SearchResultTableViewCell
        
        cell.bookmarkStarButton.tag = indexPath.row
        cell.bookmarkStarButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: UIControl.Event.touchUpInside)
        if recipeRecentlyDeleted == false {
            cell.updateCell(with: savedRecipes[indexPath.row])
        } else {
            cell.updateCell(with: oldRecipesIncludedDeletedOnes[indexPath.row])
        }
        cell.selectionStyle = .none
        return cell
    }
    
}


// MARK: - AdMob
extension SavedRecipesViewController: GADBannerViewDelegate, GADInterstitialDelegate {
    
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
        // interstitial ad
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")

        let interstitial = GADInterstitial(adUnitID: adIDs.beforeInterstitialID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
}


// MARK: - Navigation
extension SavedRecipesViewController {

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromSavedRecipesToRecipeDetailViewController" {
            if let selectedIndexPath = savedRecipesTableView.indexPathForSelectedRow {
                let recipeDetailVC = segue.destination as! RecipeDetailViewController
                // display interstitial ad
                if interstitial.isReady && RecipesViewed.isMultipleOfThree {
                    print("interstitial ad is ready")
                    interstitial.present(fromRootViewController: self)
                }
                
                //
                if recipeRecentlyDeleted == false {
                    recipeDetailVC.recipe = savedRecipes[selectedIndexPath.row]
                } else {
                    recipeDetailVC.recipe = oldRecipesIncludedDeletedOnes[selectedIndexPath.row]
                }
            }
        }
    }
    

}
