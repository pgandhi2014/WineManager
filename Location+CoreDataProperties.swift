//
//  Location+CoreDataProperties.swift
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

extension Location {

    @NSManaged var inUse: NSNumber?
    @NSManaged var location: String?

}
