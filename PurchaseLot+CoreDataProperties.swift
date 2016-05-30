//
//  PurchaseLot+CoreDataProperties.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/30/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PurchaseLot {

    @NSManaged var purchaseDate: NSDate?
    @NSManaged var price: NSDecimalNumber?
    @NSManaged var quantity: NSNumber?
    @NSManaged var bottle: NSManagedObject?

}
