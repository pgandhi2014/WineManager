//
//  Wine+CoreDataProperties.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 8/14/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Wine {

    @NSManaged var availableBottles: NSNumber?
    @NSManaged var country: String?
    @NSManaged var drunkBottles: NSNumber?
    @NSManaged var id: String?
    @NSManaged var lastDrunkDate: NSDate?
    @NSManaged var lastPurchaseDate: NSDate?
    @NSManaged var maxPrice: NSDecimalNumber?
    @NSManaged var name: String?
    @NSManaged var points: NSNumber?
    @NSManaged var region: String?
    @NSManaged var review: String?
    @NSManaged var reviewSource: String?
    @NSManaged var varietal: String?
    @NSManaged var vintage: NSNumber?
    @NSManaged var modifiedDate: NSDate?
    @NSManaged var lots: NSSet?

}
