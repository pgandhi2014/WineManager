//
//  Bottle+CoreDataProperties.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/1/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Bottle {

    @NSManaged var country: String?
    @NSManaged var name: String?
    @NSManaged var points: NSNumber?
    @NSManaged var region: String?
    @NSManaged var review: String?
    @NSManaged var reviewSource: String?
    @NSManaged var uniqueID: NSNumber?
    @NSManaged var varietal: String?
    @NSManaged var vintage: NSNumber?
    var availableBottles: NSNumber? {
        var totalBottles = 0
        var availBottles = 0
        for (_, value) in lots!.enumerate() {
            let lot = value as! PurchaseLot
            totalBottles = totalBottles + lot.quantity!.integerValue
        }
        availBottles = totalBottles
        
        for (_, value) in statuses!.enumerate() {
            let loc = value as! Status
            if (loc.available == 0) {
                availBottles = availBottles - 1
            }
        }
        
        return availBottles
    }
    @NSManaged var lots: NSOrderedSet?
    @NSManaged var statuses: NSOrderedSet?

}
