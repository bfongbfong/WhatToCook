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
    let numberOfResults = 30
    
    // MARK: Admob
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var isShowingBannerAd = false
    
    // MARK: Activity Indicator
    var loadingView = UIView()
    let activityIndicatorView = UIActivityIndicatorView()
    
    // Operation Queue for multi-threading
    var queue = OperationQueue()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
//        getRecipes(ingredients: ingredientNames, numberOfResults: 30, ignorePantry: true)
        getRecipes()
        
        view.playLoadingAnimation(loadingView: &loadingView, activityIndicatorView: activityIndicatorView, onView: view)
        setupInterstitalAdFirstTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // maybe the index out of range error is caused by tableView reloading here when i've displaced the reload usually
        if !activityIndicatorView.isAnimating {
            tableView.reloadData()
        }
    }
}

// MARK: - UI Functions



// MARK: - Admob Methods
extension SearchResultsViewController: GADBannerViewDelegate, GADInterstitialDelegate {
    
    func setupInterstitalAdFirstTime() {
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
        isShowingBannerAd = true
        tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isShowingBannerAd && recipes.count > 0 && recipes.count == indexPath.row {
            return bannerView.frame.height
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("num of rows called")
        var bannerAddition = 0
        if isShowingBannerAd && recipes.count > 0 {
            bannerAddition = 1
        }
        
        return recipes.count + bannerAddition
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell for row at called")
        // last cell, banner space
        if isShowingBannerAd && recipes.count > 0 && recipes.count == indexPath.row {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerSpaceCell") as! BannerSpaceTableViewCell
            return cell
        }
        
        // index out of range here after i added the image downloading stuff...
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! SearchResultTableViewCell
        cell.updateCellWithUsedIngredients(with: recipes[indexPath.row])
        // got index out of bounds here after changing the spoonacular api call to be with proper parameters.
        // is this because of that? or because of the banner ad? which was an issue previously?
        // ok i just re-ran it and there was no issue. this index of out range issue happens really randomly. no idea when?
        
        cell.selectionStyle = .none
        return cell
    }
    
}


// MARK: - API Requests
extension SearchResultsViewController {
    
    func getRecipes() {
        SpoonacularManager.searchRecipesByIngredients(ingredients: ingredientNames, numberOfResults: numberOfResults, ignorePantry: true) { (json, error) in
            
            if let errorThatHappened = error {
                print(errorThatHappened.localizedDescription)
                return
            }
            self.parseJson(jsonArray: json) { recipes in
                self.recipes = recipes
                
                DispatchQueue.main.async {
                    self.view.stopLoadingAnimation(loadingView: &self.loadingView, activityIndicatorView: self.activityIndicatorView)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func parseJson(jsonArray: [Any]?, completion: @escaping((_ recipes: [Recipe]) -> Void)) {
        let group = DispatchGroup()
        var returnArrayOfRecipes = [Recipe]()
        
        let parseJsonBody = BlockOperation {

            guard let bodyJsonArray = jsonArray else { return }
            // to prevent duplicate recipes
            var setOfIDs: Set<Int> = []
            var setOfTitles: Set<String> = []
            print("JSON ARRAY ==================================================")
            print(bodyJsonArray)
                for json in bodyJsonArray {
                    
                    let recipe = Recipe()
                    guard let dictionary = json as? [String : Any] else { return }
                    
                    if let urlString = dictionary["image"] as? String {
                        recipe.imageName = urlString
                        let url = URL(string: urlString)
                        group.enter()
                        NetworkRequests.downloadImage(from: url!) { (data) in
                            recipe.imageData = data
                            let image = UIImage(data: data)
                            recipe.image = image
                            print("image downloaded")
                            group.leave()
                        }
                    } else {
                        print("unable to download image: url string not given")
                    }

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
                    
                    if let usedIngredientsArray = dictionary["usedIngredients"] as? [[String: Any]] {
                        for i in 0..<usedIngredientsArray.count {

                            let ingredient = Ingredient(
                                aisle: usedIngredientsArray[i]["aisle"] as! String,
                                amount: usedIngredientsArray[i]["amount"] as! NSNumber,
                                id: usedIngredientsArray[i]["id"] as! Int,
                                imageName: usedIngredientsArray[i]["imageName"] as? String ?? "no image name",
                                name: usedIngredientsArray[i]["name"] as! String,
                                unit: usedIngredientsArray[i]["unit"] as! String,
                                unitShort: usedIngredientsArray[i]["unitShort"] as! String)

                            recipe.usedIngredients.append(ingredient)
                        }
                    }
                    returnArrayOfRecipes.append(recipe)
                }
                group.wait()
            }
        
        let jsonDoneParsing = BlockOperation {
            print("API calls complete")
            completion(returnArrayOfRecipes)
        }
        
        jsonDoneParsing.addDependency(parseJsonBody)
        queue.addOperation(parseJsonBody)
        queue.addOperation(jsonDoneParsing)
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
