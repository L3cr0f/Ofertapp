//
//  OfferModel.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 1/4/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation
import Alamofire

struct UserModel {
    let nickName: String
    let email: String
    let password: String
    let enterprise: Bool
    let admin: Bool
    let version: Int
    let id: String
}

extension UserModel {
    
    static func loadUser(query: String) -> UserModel {
        return userModelFromMongoDB("https://users-ofertapp.herokuapp.com/todo/" + query)
    }
    
    private static func userModelFromMongoDB(url: String) -> UserModel {
        
        var dataIsReceived: Bool = false
        var userModel = UserModel!()

        Alamofire.request(.GET, url) .responseJSON { response in

            if let JSON = response.result.value {
                
                guard
                    let nickName = JSON["Name"]! as? String,
                    let email = JSON["Email"]! as? String,
                    let password = JSON["Password"]! as? String,
                    let enterprise = JSON["Enterprise"] as? Bool,
                    let admin = JSON["Admin"] as? Bool,
                    let version = JSON["__v"]! as? Int,
                    let id = JSON["_id"]! as? String
                    else {
                        fatalError("Error parsing offer \(JSON)")
                }
                
                userModel = UserModel(
                    nickName: nickName,
                    email: email,
                    password: password,
                    enterprise: enterprise,
                    admin: admin,
                    version: version,
                    id: id
                )
            }
            
            dataIsReceived = true
        }
        
        while dataIsReceived == false {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
        }
        if userModel == nil {
            userModel = UserModel(
                nickName: "",
                email: "",
                password: "",
                enterprise: false,
                admin: false,
                version: 0,
                id: ""
            )
        }
        
        return userModel
    }
}