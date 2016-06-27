//
//  Bottle+CoreDataProperties.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/26/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Bottle {

    @NSManaged var availableBottles: NSNumber?
    @NSManaged var country: String?
    @NSManaged var maxPrice: NSDecimalNumber?
    @NSManaged var name: String?
    @NSManaged var points: NSNumber?
    @NSManaged var region: String?
    @NSManaged var review: String?
    @NSManaged var reviewSource: String?
    @NSManaged var uniqueID: NSNumber?
    @NSManaged var varietal: String?
    @NSManaged var vintage: NSNumber?
    @NSManaged var drunkBottles: NSNumber?
    @NSManaged var lots: NSOrderedSet?

}
