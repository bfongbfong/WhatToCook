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
    var temporaryView = UIView()
    var firstTimeLoading = true
    var viewCenter = CGPoint()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        autocompleteQueue.maxConcurrentOperationCount = 1
        print("center: \(self.viewCenter)")

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
        viewCenter = view.center

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
    
    private func setupTemporaryView() {
        searchByRecipesTableView.layoutIfNeeded()

//        let temporaryViewFrame = CGRect(x: searchByRecipesTableView.frame.minX,
//                                        y: searchByRecipesTableView.frame.minY,
//                                        width: searchByRecipesTableView.frame.width,
//                                        height: searchByRecipesTableView.contentSize.height)
        
//        let temporaryViewFrame = CGRect(x: searchByRecipesTableView.frame.minX,
//                                        y: searchByRecipesTableView.frame.minY,
//                                        width: searchByRecipesTableView.frame.width,
//                                        height: view.frame.height)
        
        let temporaryViewFrame = CGRect(x: searchByRecipesTableView.frame.minX,
                                        y: searchByRecipesTableView.frame.minY,
                                        width: searchByRecipesTableView.frame.width,
                                        height: searchByRecipesTableView.frame.height)
        temporaryView = UIView(frame: temporaryViewFrame)
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
        
        if firstTimeLoading {
            setupTemporaryView()
            firstTimeLoading = false
        }
        
        self.view.addSubview(temporaryView)
        temporaryView.backgroundColor = .white
        temporaryView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(
        [NSLayoutConstraint(item: temporaryView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: view.safeAreaLayoutGuide,
                            attribute: .bottom,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: temporaryView,
                            attribute: .top,
                            relatedBy: .equal,
                            toItem: searchByRecipesTableView,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: temporaryView,
                            attribute: .right,
                            relatedBy: .equal,
                            toItem: view.safeAreaLayoutGuide,
                            attribute: .right,
                            multiplier: 1.0,
                            constant: 0),
         NSLayoutConstraint(item: temporaryView,
                            attribute: .left,
                            relatedBy: .equal,
                            toItem: view.safeAreaLayoutGuide,
                            attribute: .left,
                            multiplier: 1.0,
                            constant: 0),
        ])
        
//        temporaryView.playLoadingAnimation(loadingView: &loadingView, activityIndicatorView: activityIndicatorView)
        
        activityIndicatorView.style = .gray
        
//        print("center: \(self.viewCenter)")
//        activityIndicatorView.center = self.viewCenter
        temporaryView.addSubview(activityIndicatorView)

        //Don't forget this line
         activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView,
                                              attribute: NSLayoutConstraint.Attribute.centerX,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: view,
                                              attribute: NSLayoutConstraint.Attribute.centerX,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView,
                                              attribute: NSLayoutConstraint.Attribute.centerY,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: view,
                                              attribute: NSLayoutConstraint.Attribute.centerY,
                                              multiplier: 1,
                                              constant: 0))

        
        activityIndicatorView.startAnimating()
        
        let group = DispatchGroup()
        
        if currentApiCall.isExecuting {
            autocompleteQueue.cancelAllOperations()
        }
        
        currentApiCall = BlockOperation {
            group.enter()
            self.populateRecipeData(wordToSearch: text) {
                group.leave()
            }
            group.wait()
        }
        
        finishApiRequests = BlockOperation {
            OperationQueue.main.addOperation {
                self.searchByRecipesTableView.reloadData()
                self.temporaryView.removeFromSuperview()
                // this line below might be unneccessary
//                self.temporaryView.stopLoadingAnimation(loadingView: &self.loadingView, activityIndicatorView: self.activityIndicatorView)
            }
        }
        finishApiRequests.addDependency(currentApiCall)
        autocompleteQueue.addOperation(currentApiCall)
        autocompleteQueue.addOperation(finishApiRequests)
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
        SpoonacularManager.autocompleteRecipeSearch(input: wordToSearch, numberOfResults: 15) { (json) in
            self.parseJsonForRecipes(jsonArray: json) { (possibleRecipes) in
                guard let recipes = possibleRecipes else { return }
                self.recipes = recipes
                completion()
            }
        }

    }
    
    private func parseJsonForRecipes(jsonArray: [Any]?, completion: @escaping((_ recipes: [Recipe]?) -> Void)) {
        guard let bodyJsonArray = jsonArray else {
            return
        }
//        print("JSON ARRAY ==================================================")
//        print(bodyJsonArray)
            
        let group = DispatchGroup()
        var returnArrayOfRecipes = [Recipe]()
        
        let operation1 = BlockOperation {
            for jsonObject in bodyJsonArray {
                guard let recipeObject = jsonObject as? [String: Any] else { continue }
                
                guard let id = recipeObject["id"] as? Int else { continue }
                guard let title = recipeObject["title"] as? String else { continue }
                
                var recipe = Recipe()
                recipe.id = id
                recipe.title = title
                group.enter()
                SpoonacularManager.getRecipeInformation(recipeId: id) { (json, error) in
                    if let errorThatHappened = error {
                        print(errorThatHappened.localizedDescription)
                        return
                    }
                    self.parseJsonForRecipeInfo(jsonObject: json, recipe: &recipe)
                    recipe.detailsLoaded = true
//                    print("recipe: \(id) finished retrieving info")
                    group.leave()
                    
                    guard let urlString = recipe.imageName else { return }
                    let url = URL(string: urlString)
                    
                    group.enter()
                    NetworkRequests.downloadImage(from: url!) { (data) in
                        recipe.imageData = data
                        let image = UIImage(data: data)
                        recipe.image = image
//                        print("image downloaded")
                        group.leave()
                    }
                }
                
//                print("recipe: \(id) appended")
                returnArrayOfRecipes.append(recipe)
            }
            group.wait()
        }
        
        let apiCallsComplete = BlockOperation {
//            print("API calls complete")
            completion(returnArrayOfRecipes)
        }
        
        apiCallsComplete.addDependency(operation1)
        queue.addOperation(operation1)
        queue.addOperation(apiCallsComplete)
    }
    
    private func parseJsonForRecipeInfo(jsonObject: [String: Any]?, recipe: inout Recipe) {
        guard let recipeObject = jsonObject else {
            return
        }
        recipe.imageName = recipeObject["image"] as? String
        
        guard let ingredientsFound = recipeObject["extendedIngredients"] as? [[String:Any]] else { return }
        guard let ingredients = JsonParser.parseJsonToIngredientsArray(jsonArray: ingredientsFound) else { return }
        recipe.ingredients = ingredients
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

