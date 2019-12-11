//
//  NetworkRequests.swift
//  WhatToEat
//
//  Created by Brandon Fong on 12/3/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class NetworkRequests {
    
    // Helper function for downloading image
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    static func downloadImage(from url: URL, completion: @escaping((_ data: Data) -> Void)) {
//        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
            completion(data)
        }
    }
}

