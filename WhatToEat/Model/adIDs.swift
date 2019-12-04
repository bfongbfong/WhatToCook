//
//  adIDs.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class adIDs {
    static var searchResultsVCBannerID: String {
        if TestMode.testMode {
            return "ca-app-pub-3940256099942544/2934735716"
        } else {
            return "ca-app-pub-5775764210542302/4339264751"
        }
    }
    static var recipeDetailVCBannerID: String {
        if TestMode.testMode {
            return "ca-app-pub-3940256099942544/2934735716"
        } else {
            return "ca-app-pub-5775764210542302/9192273207"
        }
    }
    static var searchByRecipeNameVCBannerID: String {
        if TestMode.testMode {
            return "ca-app-pub-3940256099942544/2934735716"
        } else {
            return "ca-app-pub-5775764210542302/7631779527"
        }
    }
    static var savedRecipesVCBannerID: String {
        if TestMode.testMode {
            return "ca-app-pub-3940256099942544/2934735716"
        } else {
            return "ca-app-pub-5775764210542302/6262518225"
        }
    }
    static var beforeInterstitialID: String {
        if TestMode.testMode {
            return "ca-app-pub-3940256099942544/4411468910"
        } else {
            return "ca-app-pub-5775764210542302/6785262409"
        }
    }
}
