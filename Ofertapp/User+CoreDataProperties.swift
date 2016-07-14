//
//  User+CoreDataProperties.swift
//  
//
//  Created by Ernesto Fdez on 12/5/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var email: String?
    @NSManaged var enterprise: NSNumber?
    @NSManaged var id: String?
    @NSManaged var nickname: String?
    @NSManaged var version: NSNumber?
    @NSManaged var admin: NSNumber?

}
