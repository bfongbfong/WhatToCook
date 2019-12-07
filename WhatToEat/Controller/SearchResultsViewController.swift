//
//  SearchResultsViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/17/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest
import GoogleMobileAds

class SearchResultsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    // MARK: Data
    var ingredientNames: String = ""
    var recipes: [Recipe] = []
    
    // MARK: Admob
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    // MARK: Activity Indicator
    var loadingView = UIView()
    let activityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
//        getRecipes(ingredients: ingredientNames, numberOfResults: 30, ignorePantry: true)
        getRecipes()
        
        view.playLoadingAnimation(loadingView: &loadingView, activityIndicatorView: activityIndicatorView)
        setUpInterstitalAdFirstTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - UI Functions



// MARK: - Admob Methods
extension SearchResultsViewController: GADBannerViewDelegate, GADInterstitialDelegate {
    
    func setUpInterstitalAdFirstTime() {
        // ads
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        // real id
        bannerView.adUnitID = adIDs.searchResultsVCBannerID
        // test id
    //        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        interstitial = createAndLoadInterstitial()
    }
    
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


// MARK: - UITableView Datasource & Delegate
extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! SearchResultTableViewCell
        cell.updateCellWithUsedIngredients(with: recipes[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
}


// MARK: - API Requests
extension SearchResultsViewController {
    
    func getRecipes() {
        SpoonacularManager.searchRecipesByIngredients(ingredients: ingredientNames,
                                                      numberOfResults: 30,
                                                      ignorePantry: true) { (json, error) in
            if let errorThatHappened = error {
                print(errorThatHappened.localizedDescription)
                return
            }
            self.parseJson(jsonArray: json)
            DispatchQueue.main.async {
                self.view.stopLoadingAnimation(loadingView: &self.loadingView, activityIndicatorView: self.activityIndicatorView)
                self.tableView.reloadData()
            }
            
        }
    }
    
    private func parseJson(jsonArray: [Any]?) {
        
        guard let bodyJsonArray = jsonArray else { return }
        // to prevent duplicate recipes
        var setOfIDs: Set<Int> = []
        var setOfTitles: Set<String> = []
        print("JSON ARRAY ==================================================")
        print(bodyJsonArray)
        for json in bodyJsonArray {
           let recipe = Recipe()
           guard let dictionary = json as? [String : Any] else { return }
           let id = dictionary["id"] as? Int
           if id != nil && !setOfIDs.contains(id!) {
               setOfIDs.insert(id!)
               recipe.id = id
           } else { continue }
           guard let title = dictionary["title"] as? String else { continue }
           if !setOfTitles.contains(title) {
               setOfTitles.insert(title)
               recipe.title = dictionary["title"] as? String
           } else { continue }
           recipe.imageName = dictionary["image"] as? String
           recipe.missedIngredientCount = dictionary["missedIngredientCount"] as? Int
           recipe.usedIngredientCount = dictionary["usedIngredientCount"] as? Int
           recipe.unusedIngredientCount = dictionary["unusedIngredientCount"] as? Int
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
                   
                   recipe.missedIngredients.append(ingredient)
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
                   
                   recipe.usedIngredients.append(ingredient)
               }
           }
           
           self.recipes.append(recipe)
       }
    }
}


// MARK: - Navigation
extension SearchResultsViewController {
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToRecipeDetailViewController" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let recipeDetailVC = segue.destination as! RecipeDetailViewController
                if interstitial.isReady && RecipesViewed.isMultipleOfThree {
                    interstitial.present(fromRootViewController: self)
                }
                recipeDetailVC.recipe = recipes[selectedIndexPath.row]
                print("PREAPRE FOR SEGUE HAPPENED ")
            }
        }
        
     }
}
