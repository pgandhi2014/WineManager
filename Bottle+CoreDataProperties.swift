//
//  Bottle+CoreDataProperties.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 9/14/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Bottle {

    @NSManaged var available: NSNumber?
    @NSManaged var drunkDate: NSDate?
    @NSManaged var id: String?
    @NSManaged var location: String?
    @NSManaged var modifiedDate: NSDate?
    @NSManaged var notes: String?
    @NSManaged var rating: NSDecimalNumber?
    @NSManaged var lot: PurchaseLot?

}
