//
//  ViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/1/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rectangleForSearchButton: UIView!
    @IBOutlet weak var fridgeBarButtonItem: BadgeBarButtonItem!
    @IBOutlet var tapSearchButton: UITapGestureRecognizer!
    @IBOutlet weak var clearFridgeButton: UIBarButtonItem!
    
    // MARK: - Properties
    var searchResults: [SearchedIngredient] = []
    var savedIngredients: [SearchedIngredient] = []
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        savedIngredients = PersistenceManager.loadSavedIngredients()

        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        hideKeyboardWhenTappedAround()
        tableView.keyboardDismissMode = .onDrag
        
        setupSearchButton()
        alignTextField()
        setupNavBar()
        setupClearFridgeButton()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupStatusBar()
        alignTextFieldPlaceholderText()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


// MARK: - IBActions & Objc Functions
extension HomeViewController: UITextFieldDelegate {
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        print("EDITING CHANGED")
        
        guard let text = textField.text else {
            print("textfield.text was nil")
            return
        }
        
        guard let firstLetter = Array(text).first else {
            return
        }

        guard text != "" && firstLetter != " " else {
            searchResults.removeAll()
            tableView.reloadData()
            return
        }
        
        populateTableViewWithIngredients(text: text)
    }
    
    
    @IBAction func clearFridgeTapped(_ sender: Any) {
        savedIngredients.removeAll()
        PersistenceManager.persistSavedIngredients(savedIngredients: savedIngredients)
        updateUI()
    }
    
}


// MARK: - UI Functions
extension HomeViewController {
    
    func setupNavBar() {
        // set up nav bar
        navigationController?.navigationBar.barTintColor = UIColor.myGreen
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "PoetsenOne-Regular", size: 21)!]
    }
    
    func setupStatusBar() {
        // set up status bar
        navigationController?.navigationBar.barStyle = .black
    }
    
    func alignTextField() {
        // align textField
        textField.contentVerticalAlignment = .center
        textField.layer.cornerRadius = 15
        textField.clipsToBounds = true
    }
    
    func alignTextFieldPlaceholderText() {
        // to make "SEARCH INGREDIENTS" placeholder text fit and center vertically
        for subview in textField.subviews {
            if let label = subview as? UILabel {
                label.minimumScaleFactor = 0.3
                label.adjustsFontSizeToFitWidth = true
                label.baselineAdjustment = .alignCenters
            }
        }
        
        // add horizontal padding to "SEARCH INGREDIENTS" placeholder
        let leftPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        let rightPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
    }
    
    func setupClearFridgeButton() {
        clearFridgeButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gotham", size: 15)!], for: .normal)
        setClearFridgeButton(enabled: false)
    }
    
    func setupSearchButton() {
        rectangleForSearchButton.layer.cornerRadius = rectangleForSearchButton.frame.width/8
        rectangleForSearchButton.layer.masksToBounds = true
        rectangleForSearchButton.backgroundColor = UIColor.gray
        tapSearchButton.isEnabled = false
    }
    
    func updateUI() {
        self.fridgeBarButtonItem.badgeNumber = self.savedIngredients.count
        
        if savedIngredients.count == 0 {
            setClearFridgeButton(enabled: false)
            
            rectangleForSearchButton.backgroundColor = UIColor.gray
            tapSearchButton.isEnabled = false
            
        } else {
            self.setClearFridgeButton(enabled: true)
            
            self.rectangleForSearchButton.backgroundColor = UIColor.mySalmon
            self.tapSearchButton.isEnabled = true
        }
    }
    
    func setClearFridgeButton(enabled: Bool) {
        if enabled {
            clearFridgeButton.isEnabled = true
            clearFridgeButton.tintColor = UIColor.white.withAlphaComponent(1.0)
        } else {
            clearFridgeButton.isEnabled = false
            clearFridgeButton.tintColor = UIColor.white.withAlphaComponent(0)
        }
    }
    
}

// MARK: - Logic Functions
extension HomeViewController {
    func populateTableViewWithIngredients(text: String) {
        SpoonacularManager.autocompleteIngredientSearch(input: text) { (json, error) in
            if let thisError = error {
                print(thisError.localizedDescription)
                return
            }
            self.parseJson(jsonBody: json)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


// MARK: - UITableView Data Source & Delegate Methods
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return searchResults.count
        } else {
            return savedIngredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! AutocompleteSearchTableViewCell
        cell.updateCell(with: searchResults[indexPath.row])
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    
    // MARK: Delegate
    
    // save ingredients
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        addIngredientAnimation(indexPath: indexPath)
        
        // remove from tableView
        let ingredient = SearchedIngredient(name: searchResults[indexPath.row].name, imageName: searchResults[indexPath.row].imageName)
        searchResults.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        searchResults = []
        tableView.reloadData()
        // add to bottom tableView
        savedIngredients.append(ingredient)
        // empty text field
        textField.text = ""
        UIDevice.vibrate()
        
        PersistenceManager.persistSavedIngredients(savedIngredients: savedIngredients)
    }
    
}

extension HomeViewController {
    
    private func parseJson(jsonBody: [Any]?) {
        
        guard let json = jsonBody else { return }
        
        print("JSON ARRAY ==================================================")
        print(json)
        self.searchResults = []
        for jsonObject in json {
            if let dictionary = jsonObject as? [String: Any] {
                
                let searchedIngredient = SearchedIngredient(name: dictionary["name"] as! String, imageName: dictionary["image"] as! String)
                var matchFound = false
                for savedIngredient in self.savedIngredients {
                    if searchedIngredient == savedIngredient {
                        matchFound = true
                    }
                }
                if matchFound == false {
                    self.searchResults.append(searchedIngredient)
                }
            }
        }
    }
    
    func getSavedItemsAsRequestString() -> String {
        var resultString = ""
        for (index, ingredient) in savedIngredients.enumerated() {
            if index != 0 {
                resultString += "%2C+"
            }
            let nameOfIngredientWithoutSpaces = replaceSpecialCharacters(input: ingredient.name)
            resultString += nameOfIngredientWithoutSpaces
        }
        return resultString
    }
    
    
}


// MARK: - Animations
extension HomeViewController {
    
    func addIngredientAnimation(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AutocompleteSearchTableViewCell
        
        let imageViewPosition : CGPoint = cell.ingredientImage.convert(cell.ingredientImage.bounds.origin, to: self.view)
        
        let imgViewTemp = UIImageView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: cell.ingredientImage.frame.size.width, height: cell.ingredientImage.frame.size.height))
        
        imgViewTemp.image = cell.ingredientImage.image
        
        jumpToCartAnimation(tempView: imgViewTemp)
    }
    
    // second part of jump to cart
    func jumpToCartAnimation(tempView : UIView)  {
        self.view.addSubview(tempView)

        UIView.animate(withDuration: 0.5, animations: {
            
            tempView.animationZoom(scaleX: 0.2, y: 0.2)
            tempView.animationRoted(angle: CGFloat(Double.pi))
            
            tempView.frame.origin.x = self.navigationController!.navigationBar.center.x + 5
            tempView.frame.origin.y = self.navigationController!.navigationBar.center.y
            
        }, completion: { _ in
            
            tempView.removeFromSuperview()
            self.updateUI()
        })
    }

    
}


// MARK: - Navigation
extension HomeViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "ToSearchResults" {
            if let destinationVC = segue.destination as? SearchResultsViewController {
        
                
                if savedIngredients.count == 0 {
                    
                } else {
                    let ingredientNames = savedIngredients.map({ $0.name })
                    let ingredientNamesWithoutSpaces = ingredientNames.map({
                        $0.replacingOccurrences(of: " ", with: "+")})
                    let ingredientsString = ingredientNamesWithoutSpaces.joined(separator: "%2C")
                    destinationVC.ingredientNames = ingredientsString
                }
            }
        } else if segue.identifier == "ToSavedIngredients" {
            if let destinationVC = segue.destination as? SavedIngredientViewController {
                destinationVC.savedIngredients = savedIngredients
            }
        }
    }
}

// global function
func replaceSpecialCharacters(input: String) -> String {
    var returnString = input.replacingOccurrences(of: " ", with: "+")
    returnString = returnString.replacingOccurrences(of: "‘", with: "\'")
    returnString = returnString.replacingOccurrences(of: "’", with: "\'")
    // this stuff isn't working below... above is working though
    returnString = returnString.replacingOccurrences(of: "“", with: "\"")
    returnString = returnString.replacingOccurrences(of: "”", with: "\"")
    returnString = returnString.replacingOccurrences(of: "\"", with: "")
    returnString = returnString.replacingOccurrences(of: "\\", with: "")

// *********** STUCK ON WHY THE API REQUEST FAILS IF YOU TYPE A DOUBLE QUOTE

//    returnString = returnString.replacingOccurrences(of: "'", with: "")

    returnString = returnString.replacingOccurrences(of: "\"", with: "\"")
//    returnString = returnString.typographized(language: "en")
    return returnString
}







