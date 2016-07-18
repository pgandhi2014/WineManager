//
//  XMLHelper.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/15/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import Foundation
import CoreData

class XMLHelper: NSObject, NSXMLParserDelegate {
    var managedObjectContext: NSManagedObjectContext? = nil

    private let dateFormatter = NSDateFormatter()
    private var parser = NSXMLParser()
    private var element = NSString()
    private var parsedBottle = ParsedWineBottle()
    private var parsedLot = ParsedLot(purchaseDate: "", price: "", quantity: "", locations: [ParsedLoc]())
    private var parsedLoc = ParsedLoc(status: "", location: "", drunkDate: "", rating: "", notes: "")

    init(moc: NSManagedObjectContext) {
        super.init()
        //self.managedObjectContext = moc
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = moc.persistentStoreCoordinator
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let path = NSBundle.mainBundle().pathForResource("NewWineList", ofType: "xml")
        if path != nil {
            parser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path!))!
        } else {
            NSLog("Failed to find xml")
        }
        parser.delegate = self
    }
    
    func startParsing() {
        parser.parse()
    }

    // MARK: - Parser
    @objc internal func parserDidEndDocument(parser: NSXMLParser) {
        saveContext()
    }
    
    @objc internal func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as String
        
        if elementName == "bottle" {
            parsedBottle.Erase()
        } else if elementName == "Lot" {
            parsedLot.Erase()
        } else if elementName == "Loc" {
            parsedLoc.Erase()
        }
        
    }
    
    @objc internal func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if element.isEqualToString("Name") {
            if (parsedBottle.name.isEmpty) {
                parsedBottle.name = parsedBottle.name + string
                NSLog (string)
            }
        } else if element.isEqualToString("Vintage") {
            if (parsedBottle.vintage.isEmpty) {
                parsedBottle.vintage = parsedBottle.vintage + string
            }
        } else if element.isEqualToString("Varietal") {
            if (parsedBottle.varietal.isEmpty) {
                parsedBottle.varietal = parsedBottle.varietal + string
            }
        } else if element.isEqualToString("Region") {
            if (parsedBottle.region.isEmpty) {
                parsedBottle.region = parsedBottle.region + string
            }
        } else if element.isEqualToString("Country") {
            if (parsedBottle.country.isEmpty) {
                parsedBottle.country = parsedBottle.country + string
            }
        } else if element.isEqualToString("ReviewSource") {
            if (parsedBottle.reviewSource.isEmpty) {
                parsedBottle.reviewSource = parsedBottle.reviewSource + string
            }
        } else if element.isEqualToString("Points") {
            if (parsedBottle.points.isEmpty) {
                parsedBottle.points = parsedBottle.points + string
            }
        } else if element.isEqualToString("Review") {
            if (parsedBottle.review.isEmpty) {
                parsedBottle.review = parsedBottle.review + string
            }
        } else if element.isEqualToString("PurchaseDate") {
            if (parsedLot.purchaseDate.isEmpty) {
                parsedLot.purchaseDate = parsedLot.purchaseDate + string
            }
        } else if element.isEqualToString("Price") {
            if (parsedLot.price.isEmpty) {
                parsedLot.price = parsedLot.price + string
            }
        } else if element.isEqualToString("Quantity") {
            if (parsedLot.quantity.isEmpty) {
                parsedLot.quantity = parsedLot.quantity + string
            }
        } else if element.isEqualToString("Status") {
            if (parsedLoc.status.isEmpty) {
                parsedLoc.status = parsedLoc.status + string
            }
        } else if element.isEqualToString("Location") {
            if (parsedLoc.location.isEmpty && !(string.containsString("\n") || string.isEmpty)) {
                parsedLoc.location = parsedLoc.location + string
                NSLog (string)
            }
        } else if element.isEqualToString("DrunkDate") {
            if (parsedLoc.drunkDate.isEmpty && !string.containsString("\n")) {
                parsedLoc.drunkDate = parsedLoc.drunkDate + string
            }
        } else if element.isEqualToString("Rating") {
            if (parsedLoc.rating.isEmpty && !string.containsString("\n")) {
                parsedLoc.rating = parsedLoc.rating + string
            }
        } else if element.isEqualToString("Notes") {
            if (parsedLoc.notes.isEmpty && !string.containsString("\n")) {
                parsedLoc.notes = parsedLoc.notes + string
            }
        }
    }
    
    @objc internal func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName == "bottle") {
            insertNewBottle()
        } else if (elementName == "Lot") {
            parsedBottle.purchaseLots.addObject(parsedLot.copy())
        } else if (elementName == "Loc") {
            parsedLot.locations.append(parsedLoc.copy() as! ParsedLoc)
        }
    }

    internal func insertNewBottle() {
        let newBottle = NSEntityDescription.insertNewObjectForEntityForName("Bottle", inManagedObjectContext: self.managedObjectContext!) as! Bottle
        
        newBottle.name = parsedBottle.name
        if let myNumber = NSNumberFormatter().numberFromString(parsedBottle.vintage) {
            newBottle.vintage = myNumber
        }
        newBottle.varietal = parsedBottle.varietal
        newBottle.region = parsedBottle.region
        newBottle.country = parsedBottle.country
        
        newBottle.reviewSource = parsedBottle.reviewSource
        if let myNumber = NSNumberFormatter().numberFromString(parsedBottle.points) {
            newBottle.points = myNumber
        }
        newBottle.review = parsedBottle.review
        
        for (_, value) in parsedBottle.purchaseLots.enumerate() {
            let newLot = NSEntityDescription.insertNewObjectForEntityForName("PurchaseLot", inManagedObjectContext: self.managedObjectContext!) as! PurchaseLot
            let lot = value as! ParsedLot
            newLot.bottle = newBottle
            newLot.purchaseDate = self.dateFormatter.dateFromString(lot.purchaseDate)
            if (newLot.purchaseDate!.compare(newBottle.lastPurchaseDate!) == NSComparisonResult.OrderedDescending) {
                newBottle.lastPurchaseDate = newLot.purchaseDate
            }
            if let myNumber = NSNumberFormatter().numberFromString(lot.price) {
                newLot.price = NSDecimalNumber(decimal: myNumber.decimalValue)
                if (newLot.price!.compare(newBottle.maxPrice!) == NSComparisonResult.OrderedDescending) {
                    newBottle.maxPrice = newLot.price
                }
            }
            if let myNumber = NSNumberFormatter().numberFromString(lot.quantity) {
                newLot.quantity = myNumber
            }
            
            for (_, value) in lot.locations.enumerate() {
                let newLoc = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: self.managedObjectContext!) as! Status
                let loc = value
                newLoc.lot = newLot
                if let myDate = self.dateFormatter.dateFromString(loc.drunkDate) {
                    newLoc.drunkDate = myDate
                    if (newLoc.drunkDate!.compare(newBottle.lastDrunkDate!) == NSComparisonResult.OrderedDescending) {
                        newBottle.lastDrunkDate = newLoc.drunkDate
                    }
                }
                if (loc.status == "Drunk") {
                    newLoc.available = 0
                    newLot.drunkBottles = (newLot.drunkBottles?.integerValue)! + 1
                } else {
                    newLoc.available = 1
                    newLot.availableBottles = (newLot.availableBottles?.integerValue)! + 1
                }
                newLoc.location = loc.location
                newLoc.notes = loc.notes
                if let myNumber = NSNumberFormatter().numberFromString(loc.rating) {
                    newLoc.rating = NSDecimalNumber(decimal: myNumber.decimalValue)
                }
            }
            newBottle.availableBottles = (newBottle.availableBottles?.integerValue)! + (newLot.availableBottles?.integerValue)!
            newBottle.drunkBottles = (newBottle.drunkBottles?.integerValue)! + (newLot.drunkBottles?.integerValue)!
        }
    }
    
    func saveContext() {
        do {
            try self.managedObjectContext!.save()
        } catch {
            abort()
        }
    }
}
