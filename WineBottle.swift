//
//  WineBottle.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/30/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import Foundation

struct SimpleLot {
    var purchaseDate: NSDate = NSDate()
    var bottlePrice: Float = 0.0
    var totalBottles: Int = 0
    var locations = [String:Int]()
}


class ParsedLoc : NSObject, NSCopying {
    var status: String = ""
    var location: String = ""
    var drunkDate: String = ""
    var rating: String = ""
    var notes: String = ""
    
    init(status: String, location: String, drunkDate: String, rating: String, notes: String) {
        self.status = status
        self.location = location
        self.drunkDate = drunkDate
        self.rating = rating
        self.notes = notes
    }
    
    func Erase() {
        status = ""
        location = ""
        drunkDate = ""
        rating = ""
        notes = ""
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ParsedLoc(status: status, location: location, drunkDate: drunkDate, rating: rating, notes: notes)
        return copy
    }
}

class ParsedLot : NSObject, NSCopying {
    var purchaseDate: String = ""
    var price: String = ""
    var quantity: String = ""
    var locations = [ParsedLoc]()
    
    init(purchaseDate: String, price: String, quantity: String, locations: [ParsedLoc]) {
        self.purchaseDate = purchaseDate
        self.price = price
        self.quantity = quantity
        self.locations = locations
    }
    
    func Erase() {
        purchaseDate = ""
        price = ""
        quantity = ""
        locations.removeAll()
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ParsedLot(purchaseDate: purchaseDate, price: price, quantity: quantity, locations: locations)
        return copy
    }
}


class ParsedWineBottle {
    var name: String = ""
    var vintage: String = ""
    var varietal: String = ""
    var region: String = ""
    var country: String = ""
    var reviewSource: String = ""
    var points: String = ""
    var review: String = ""
    var purchaseLots: NSMutableArray = []
    
    
    func Erase() {
        name = ""
        vintage = ""
        varietal = ""
        region = ""
        country = ""
        reviewSource = ""
        points = ""
        review = ""
        purchaseLots.removeAllObjects()
    }
}
