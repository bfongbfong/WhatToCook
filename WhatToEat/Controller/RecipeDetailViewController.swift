//
//  RecipeDetailViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/1/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest
import GoogleMobileAds

class RecipeDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    var recipe: Recipe!
    var recipeDetailView: RecipeDetailView!
    
    let ingredientsCellHeight = 25
    let instructionsCellHeight = 50
    
    var loadingView: UIView!
    let activityIndicatoryView = UIActivityIndicatorView()
    
    // Admob
    var bannerView: GADBannerView!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // old code that arjun put to instantiate nib
//        let recipeDetailViewActual = RecipeDetailView.instanceFromNib() as! RecipeDetailView
        
        recipeDetailView = RecipeDetailView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 2000))
        recipeDetailView.layoutIfNeeded()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: recipeDetailView.frame.height)
        scrollView.addSubview(recipeDetailView)
        
        recipeDetailView.frame.size.height = recipeDetailView.contentView.frame.height

        populateInstructions()
        recipeDetailView.dietsCollectionView.delegate = self
        recipeDetailView.dietsCollectionView.dataSource = self
        recipeDetailView.ingredientsTableView.delegate = self
        recipeDetailView.ingredientsTableView.dataSource = self
        recipeDetailView.instructionsTableView.delegate = self
        recipeDetailView.instructionsTableView.dataSource = self
        recipeDetailView.dietsCollectionView.register(UINib(nibName: "DietCollectionViewCellView", bundle: nil), forCellWithReuseIdentifier: "DietCollectionViewCell")
        
        recipeDetailView.ingredientsTableView.register(UINib(nibName: "RecipeIngredientTableViewCellView", bundle: nil), forCellReuseIdentifier: "RecipeIngredientTableViewCell")
        
        recipeDetailView.instructionsTableView.register(UINib(nibName: "RecipeInstructionTableViewCellView", bundle: nil), forCellReuseIdentifier: "RecipeInstructionTableViewCell")
        
        recipeDetailView.instructionsTableView.register(UINib(nibName: "SourceTableViewCellView", bundle: nil), forCellReuseIdentifier: "SourceTableViewCell")
        
        
        recipeDetailView.recipeTitleLabel.numberOfLines = 2
        recipeDetailView.instructionsTableView.rowHeight = UITableView.automaticDimension
        recipeDetailView.instructionsTableView.estimatedRowHeight = CGFloat(instructionsCellHeight)
        
        recipeDetailView.dietsCollectionView.layer.cornerRadius = 5
        
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        loadingView.backgroundColor = .white
        self.view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        
        activityIndicatoryView.style = .gray
        activityIndicatoryView.center = CGPoint(x: view.center.x, y: view.center.y)
        activityIndicatoryView.startAnimating()
        loadingView.addSubview(activityIndicatoryView)
        
        setBookmarkStar()
        
        // ads
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        // real id
        bannerView.adUnitID = adIDs.recipeDetailVCBannerID
        // test id
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        RecipesViewed.counter += 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if PersistenceManager.bookmarkedRecipeIDs.contains(number: recipe.id!) {
            recipe.bookmarked = true
        } else {
            recipe.bookmarked = false
        }
        setBookmarkStar()
    }

}


// MARK: - IBActions & Objc Functions
extension RecipeDetailViewController {
    
    @objc func goToSource() {
        print("go to source called")
        if let sourceUrl = URL(string: recipe.source!) {
            UIApplication.shared.open(sourceUrl, options: [:], completionHandler: nil)
        }
    }
    
    @objc func bookmark() {
        UIDevice.vibrate()
        recipe.bookmarked = !recipe.bookmarked
        setBookmarkStar()
    }
}


// MARK: - UI Functions
extension RecipeDetailViewController {
    
    func setupUI() {
        let url = URL(string: recipe.imageName!)!
        NetworkRequests.downloadImage(from: url) { (data) in
            DispatchQueue.main.async() {
                self.recipeDetailView.recipeImageView.image = UIImage(data: data)
            }
        }
        
        let titleText = recipe.title
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.lineSpacing = 6
        titleStyle.lineBreakMode = .byTruncatingTail
        let attributedString = NSMutableAttributedString(string: titleText ?? "")
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleStyle, range: NSMakeRange(0, attributedString.length))

          
        recipeDetailView.recipeTitleLabel.attributedText = attributedString
        if let readyInMinutes = recipe.readyInMinutes {
            recipeDetailView.readyInMinutesLabel.text = "\(readyInMinutes) MIN"
        } else {
            recipeDetailView.readyInMinutesLabel.text = "N/A"
        }
        if let servings = recipe.servings {
            if servings == 1 {
                recipeDetailView.servingsLabel.text = "\(servings) SERVING"
            } else {
                recipeDetailView.servingsLabel.text = "\(servings) SERVINGS"
            }
        } else {
            recipeDetailView.servingsLabel.text = "N/A"
        }

        recipeDetailView.sourceButton.setTitle("Source: \(recipe.creditsText ?? "N/A")", for: .normal)
        // diets collection view

        recipeDetailView.sourceButton.addTarget(self, action: #selector(goToSource), for: .touchUpInside)
        recipeDetailView.bookmarkButton.addTarget(self, action: #selector(bookmark), for: .touchUpInside)
    }
    
    func setBookmarkStar() {

        if recipe.bookmarked {
            recipeDetailView.bookmarkButton.setImage(UIImage(named: "bookmark_02"), for: .normal)
        } else {
            recipeDetailView.bookmarkButton.setImage(UIImage(named: "bookmark_01"), for: .normal)
        }
        print(recipe.bookmarked)
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            
            self.loadingView.removeFromSuperview()
            self.activityIndicatoryView.stopAnimating()
            self.activityIndicatoryView.removeFromSuperview()
            
            self.setupUI()
            self.recipeDetailView.dietsCollectionView.reloadData()
            self.recipeDetailView.ingredientsTableView.reloadData()
            self.recipeDetailView.ingredientsTableViewHeightConstraint.constant = CGFloat(self.recipe.ingredients.count * self.ingredientsCellHeight)

            
            self.recipeDetailView.instructionsTableView.reloadData()
            // resize the instruction height to the right one
            
            // this is the method that multiples the cell height
            var numberOfCells = 0
            for i in 0..<self.recipe.instructions.count {
                for _ in 1..<self.recipe.instructions[i].count {
                    // it starts with 1 because the first element is the title
                    numberOfCells += 1
                }
            }
            numberOfCells += self.recipe.instructions.count - 1
            // add the number of section headers
            self.recipeDetailView.instructionsTableViewHeightConstraint.constant = CGFloat(numberOfCells * self.instructionsCellHeight)
            // commented out this 8/31 to see if i could fix source button issue
            //                        self.recipeDetailView.instructionsTableView.reloadData()
            self.recipeDetailView.instructionsTableView.layoutIfNeeded()
            
            self.recipeDetailView.instructionsTableViewHeightConstraint.constant = self.recipeDetailView.instructionsTableView.contentSize.height
            
            self.recipeDetailView.layoutIfNeeded()
            
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.recipeDetailView.contentView.frame.size.height)
            
            self.recipeDetailView.dietCollectionViewHeightConstraint.constant = 25
            self.recipeDetailView.dietsCollectionView.reloadData()
            self.recipeDetailView.dietsCollectionView.layoutIfNeeded()
            self.recipeDetailView.dietCollectionViewHeightConstraint.constant = self.recipeDetailView.dietsCollectionView.contentSize.height
            
            self.recipeDetailView.layoutIfNeeded()
            
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.recipeDetailView.contentView.frame.size.height)
        }
    }
}

// MARK: - Logic Functions
extension RecipeDetailViewController {
    
    func populateInstructions() {
        
        guard let recipeId = self.recipe.id else { return }
        
        if recipe.detailsLoaded {
            self.updateUI()
            return
        }
        
        SpoonacularManager.getRecipeInformation(recipeId: recipeId) { (data, error) in
            
            if let errorThatHappened = error {
                print(errorThatHappened.localizedDescription)
                return
            }
            
            self.parseJson(json: data)
            self.updateUI()
        }
    }
    
    private func parseJson(json: [String: Any]?) {
        
        guard let bodyJsonObject = json else { return }
        
        self.recipe.source = bodyJsonObject["sourceUrl"] as? String
        self.recipe.servings = bodyJsonObject["servings"] as? Int
        self.recipe.readyInMinutes = bodyJsonObject["readyInMinutes"] as? Int
        self.recipe.diets = bodyJsonObject["diets"] as? [String]
        self.recipe.title = bodyJsonObject["title"] as? String
        self.recipe.creditsText = bodyJsonObject["creditsText"] as? String
        
        if let ingredientsArray = bodyJsonObject["extendedIngredients"] as? [[String:Any]] {
            // so ingredients don't get repeat added
            self.recipe.ingredients.removeAll()
            var ingredientNames: Set<String> = []
            for ingredient in ingredientsArray {
                let ingredientName = ingredient["name"] as? String
                if ingredientName != nil && ingredientNames.contains(ingredientName!) {
                    continue
                } else {
                    ingredientNames.insert(ingredientName!)
                }
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
                self.recipe.ingredients.append(newIngredient)
            }
        }
        
        let analyzedInstructions = bodyJsonObject["analyzedInstructions"] as! [NSDictionary]
        // so instructions don't get repeat added
        self.recipe.instructions.removeAll()
        for (index, section) in analyzedInstructions.enumerated() {
            if let sectionName = section["name"] as? String {
                self.recipe.instructions.append([sectionName])
                if let sectionInstructions = section["steps"] as? [ [String : Any] ] {
                    for instructionInfo in sectionInstructions {
                        if let singleStep = instructionInfo["step"] as? String {
                            self.recipe.instructions[index].append(singleStep)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - UICollectionView Data Source, Delegate, DelegateFlowLayout Methods
extension RecipeDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipe.diets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = recipeDetailView.dietsCollectionView.dequeueReusableCell(withReuseIdentifier: "DietCollectionViewCell", for: indexPath) as! DietCollectionViewCell
        cell.dietLabel.text = recipe.diets?[indexPath.row]
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/4, height: view.frame.width/12)
    }
}


// MARK: - UITableView Data Source Methods
extension RecipeDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.recipeDetailView.ingredientsTableView {
            return recipe.ingredients.count
        } else if tableView == self.recipeDetailView.instructionsTableView {
            return recipe.instructions.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.recipeDetailView.ingredientsTableView {
            return recipe.ingredients.count
        } else if tableView == self.recipeDetailView.instructionsTableView {
            // instructions table view
            if recipe.instructions[section].count == 0 {
                return 0
            } else {
                return recipe.instructions[section].count - 1
            }
        } else {
            return 0
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populating the ingredients with or without units and amounts
        if tableView == self.recipeDetailView.ingredientsTableView {
            let cell = recipeDetailView.ingredientsTableView.dequeueReusableCell(withIdentifier: "RecipeIngredientTableViewCell") as! RecipeIngredientTableViewCell
            if let amount = recipe.ingredients[indexPath.row].amount {
                if recipe.ingredients[indexPath.row].unitShort != nil && recipe.ingredients[indexPath.row].unitShort != "" {
                    let unit = recipe.ingredients[indexPath.row].unitShort!
                    if let name = recipe.ingredients[indexPath.row].name {
                        cell.ingredientLabel.text = "• \(amount) \(unit) \(name)"
                    }
                } else {
                    if let name = recipe.ingredients[indexPath.row].name {
                        cell.ingredientLabel.text = "• \(amount) \(name)"
                    }
                }
            } else {
                if let name = recipe.ingredients[indexPath.row].name {
                    cell.ingredientLabel.text = "• \(name)"
                }
            }
            
            cell.selectionStyle = .none
            return cell
        } else {
            // instructions table view
            
            // if there are no instructions
            if recipe.instructions[0].count == 0 {
                let cell = recipeDetailView.instructionsTableView.dequeueReusableCell(withIdentifier: "SourceTableViewCell") as! SourceTableViewCell
                cell.selectionStyle = .none
                if let sourceText = recipe.creditsText {
                    cell.sourceButton.setTitle("See full recipe at \(sourceText) >>", for: .normal)
                    cell.sourceButton.titleLabel?.font = UIFont(name: "Gotham", size: 17)
                    cell.sourceButton.addTarget(self, action: #selector(goToSource), for: .touchUpInside)
                } else if recipe.source != nil {
                    cell.sourceButton.setTitle("See full recipe here >>", for: .normal)
                    cell.sourceButton.titleLabel?.font = UIFont(name: "Gotham", size: 17)
                    cell.sourceButton.addTarget(self, action: #selector(goToSource), for: .touchUpInside)
                }
                
                return cell
            } else {
                // there are instructions
                
            
            let cell = recipeDetailView.instructionsTableView.dequeueReusableCell(withIdentifier: "RecipeInstructionTableViewCell") as! RecipeInstructionTableViewCell
                
                // here is where you would differentiate if there are more sections in instructions.
                cell.instructionNumberLabel.text = "\(indexPath.row + 1)"
                
                // setting instruction text and line height
                let instructionText = recipe.instructions[indexPath.section][indexPath.row + 1]
                let instructionStyle = NSMutableParagraphStyle()
                instructionStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: instructionText)
                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: instructionStyle, range: NSMakeRange(0, attributedString.length))
                cell.recipeInstructionLabel.attributedText = attributedString
                
                cell.selectionStyle = .none
                return cell

            }
         }
    }
}



// MARK: - UITableView Delegate Methods
extension RecipeDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        if tableView == self.recipeDetailView.instructionsTableView {
            if recipe.instructions.count == 0 {
                return nil
            } else {
                if recipe.instructions[section].count == 0 {
                    return nil
                } else {
                    label.text = recipe.instructions[section][0].uppercased()
                    label.font = UIFont(name: "Gotham", size: 17)
                    label.frame = CGRect(x: 0, y: 5, width: self.recipeDetailView.instructionsTableView.frame.width, height: 35)
                    view.addSubview(label)
                    return view
                }
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.recipeDetailView.instructionsTableView {
            if recipe.instructions.count == 0 {
                return 0
            } else {
                if recipe.instructions[section].count == 0 {
                    return 0
                } else {
                    if recipe.instructions[section][0] == "" {
                        // for when the first step has no name
                        return 0
                    } else {
                        return 45
                    }
                }
            }
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.recipeDetailView.instructionsTableView {
            if recipe.instructions.count == 0 {
                return nil
            } else {
                if recipe.instructions[section].count == 0 {
                    return nil
                } else {
                    return recipe.instructions[section][0]
                }
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.recipeDetailView.ingredientsTableView {
            return CGFloat(ingredientsCellHeight)
        } else {
            // instructions
//            return CGFloat(instructionsCellHeight)
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.recipeDetailView.ingredientsTableView {
            return UITableView.automaticDimension
        } else {
            // instructions
            return CGFloat(instructionsCellHeight)
//            return UITableView.automaticDimension
        }
    }
}


// MARK: - Admob Methods
extension RecipeDetailViewController: GADBannerViewDelegate {
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
}


