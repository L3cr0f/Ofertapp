//
//  OfferModel.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 1/4/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation
import Alamofire

struct OffersModel {
    let name: String
    let description: String
    let category: String
    let location: String
    let startDate: String
    let endDate: String
    let user: String
    let version: Int
    let id: String
}

extension OffersModel {
    
    static func loadOffers() -> [OffersModel] {
        return loadOffersFromMongoDB("https://offers-ofertapp.herokuapp.com/todo")
    }
    
    private static func loadOffersFromMongoDB(url: String) -> [OffersModel] {
        
        var jsonArray:NSMutableArray?
        let semaphore = dispatch_semaphore_create(0)
        var offerModel = [OffersModel]()
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                jsonArray = JSON as? NSMutableArray
                
                for item in jsonArray! {
                    
                    var auxLocation : String? = ""
                    
                    if item["Location"] === nil {
                        
                    } else {
                        auxLocation = (item["Location"] as? String)!
                    }
                    
                    guard
                        let name = item["Name"]! as? String,
                        let description = item["Description"]! as? String,
                        let category = item["Category"]! as? String,
                        let location = auxLocation,
                        let startDate = item["StartDate"]! as? String,
                        let endDate = item["EndDate"]! as? String,
                        let user = item["User"]! as? String,
                        let version = item["__v"]! as? Int,
                        let id = item["_id"]! as? String
                    
                        else {
                            fatalError("Error parsing offer \(item)")
                    }
                    
                    let tempOfferModel = OffersModel(
                        name: name,
                        description: description,
                        category: category,
                    	location: location,
                        startDate: startDate,
                        endDate: endDate,
                        user: user,
                        version: version,
                        id: id
                    )
                    
                    offerModel.append(tempOfferModel)
                }
                
                dispatch_semaphore_signal(semaphore)
                
            } else {
                print("ERROR: the data is unavailable")
            }
        }
        
        while dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) != 0 {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 10))
        }

        return offerModel
    }
}