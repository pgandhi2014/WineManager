//
//  Bottle+CoreDataProperties.swift
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

extension Bottle {

    @NSManaged var name: String?
    @NSManaged var vintage: NSNumber?
    @NSManaged var varietal: String?
    @NSManaged var region: String?
    @NSManaged var country: String?
    @NSManaged var reviewSource: String?
    @NSManaged var points: NSNumber?
    @NSManaged var review: String?
    @NSManaged var uniqueID: NSNumber?
    @NSManaged var lots: NSOrderedSet?
    @NSManaged var statuses: NSOrderedSet?

}
