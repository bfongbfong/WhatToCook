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

class SearchByRecipesViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchByRecipesTableView: UITableView!
    
    // MARK: - Properties
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var recipes: [Recipe] = []
    var timer: Timer?
    var queue = OperationQueue()
    var autocompleteQueue = OperationQueue()
    var currentApiCall = BlockOperation()
    var finishApiRequests = BlockOperation()
    
    // MARK: Activity Indicator
    var loadingView = UIView()
    let activityIndicatorView = UIActivityIndicatorView()
    var firstTimeLoading = true
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        autocompleteQueue.maxConcurrentOperationCount = 1

        hideKeyboardWhenTappedAround()
        searchByRecipesTableView.dataSource = self
        searchByRecipesTableView.delegate = self
        searchTextField.delegate = self

        searchByRecipesTableView.keyboardDismissMode = .onDrag
        
        setupTextFieldOnLoad()
        setupNavigationController()
        
        setupAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchByRecipesTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPlaceholderText()
    }
}

// MARK: - UI Setup
extension SearchByRecipesViewController {
    private func setupTextFieldOnLoad() {
        searchTextField.contentVerticalAlignment = .center
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        searchTextField.clearButtonMode = .whileEditing
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor.myGreen
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "PoetsenOne-Regular", size: 21)!]
    }
    
    private func setupPlaceholderText() {
        // to make "SEARCH INGREDIENTS" placeholder text fit and center vertically
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
    
    private func setupAds() {
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

}

// MARK: - IBActions & Objc Functions
extension SearchByRecipesViewController {
    
    @objc func getAutocomplete() {
        guard let text = searchTextField.text else {
            print("textfield.text was nil")
            recipes.removeAll()
            searchByRecipesTableView.reloadData()
            return
        }
        
        guard let firstLetter = Array(text).first else {
            recipes.removeAll()
            searchByRecipesTableView.reloadData()
            return
        }

        guard text != "" && firstLetter != " " else {
            recipes.removeAll()
            searchByRecipesTableView.reloadData()
            return
        }
        
        view.playLoadingAnimation(loadingView: &loadingView, activityIndicatorView: activityIndicatorView, onView: searchByRecipesTableView)
        
        populateRecipeData(wordToSearch: text) {
            DispatchQueue.main.async {
                self.searchByRecipesTableView.reloadData()
                self.view.stopLoadingAnimation(loadingView: &self.loadingView, activityIndicatorView: self.activityIndicatorView)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension SearchByRecipesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TEXT FIELD SHOULD RETURN")
        getAutocomplete()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - UITableView Data Source & Delegate
extension SearchByRecipesViewController: UITableViewDataSource, UITableViewDelegate {
    
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
}

// MARK: - Admob
extension SearchByRecipesViewController: GADBannerViewDelegate, GADInterstitialDelegate {
    
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

// MARK: - Logic Functions
extension SearchByRecipesViewController {
    
    func populateRecipeData(wordToSearch: String, completion: @escaping(() -> Void)) {
        
        let serialQueue = DispatchQueue(label: "myqueue")
        
        SpoonacularManager.searchRecipes(input: wordToSearch, numberOfResults: 15) { bodyJsonObject, error in
            guard let bodyJsonObject = bodyJsonObject else { return }
            guard let arrayOfRecipes = bodyJsonObject["results"] as? [[String: Any]] else { return }
            
            self.recipes.removeAll()
            
            for recipeJson in arrayOfRecipes {
                self.queue.addOperation {
                    self.parseJsonForARecipe(jsonBody: recipeJson) { (recipe) in
                        print("FINISHED with \(recipe!.id!)")
                        // add recipe to something
                        if let recipe = recipe {
                            serialQueue.sync {
                                self.recipes.append(recipe)
                            }
                        }
                    }
                }
            }
            self.queue.addOperation {
                completion()
            }
        }
        

    }
    
    private func parseJsonForARecipe(jsonBody: [String: Any], completion: @escaping((_ recipes: Recipe?) -> Void)) {
//        guard let jsonBody = jsonBody else {
//            completion(nil)
//            return
//        }
        let recipe = Recipe()
        
        // things that are required to exist
        guard let id = jsonBody["id"] as? Int else { return }
        print("parsejson for a recipe started with \(id)")
        guard let title = jsonBody["title"] as? String else { return }
        guard let imageName = jsonBody["image"] as? String else { return }
        
        recipe.id = id
        recipe.title = title
        recipe.imageName = imageName
        
        // things that are less neccessary
        if let readyInMinutes = jsonBody["readyInMinutes"] as? Int {
            recipe.readyInMinutes = readyInMinutes
        } else {
            // no ready in minutes
            // maybe i'll just leave these two blank so they'll be nil and handle that later in view
        }
        if let servings = jsonBody["servings"] as? Int {
            recipe.servings = servings
        } else {
            // no servings
        }
        
        completion(recipe)
    }
}


// MARK: - Navigation
extension SearchByRecipesViewController {
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

