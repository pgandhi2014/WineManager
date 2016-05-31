//
//  WineBottle.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/30/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import Foundation

class Lot : NSObject, NSCopying {
    var purchaseDate: String = ""
    var price: String = ""
    var quantity: String = ""
    
    init(purchaseDate: String, price: String, quantity: String) {
        self.purchaseDate = purchaseDate
        self.price = price
        self.quantity = quantity
    }
    
    func Erase() {
        purchaseDate = ""
        price = ""
        quantity = ""
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Lot(purchaseDate: purchaseDate, price: price, quantity: quantity)
        return copy
    }
}

class Loc : NSObject, NSCopying {
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
        let copy = Loc(status: status, location: location, drunkDate: drunkDate, rating: rating, notes: notes)
        return copy
    }
}

class WineBottle {
    var name: String = ""
    var vintage: String = ""
    var varietal: String = ""
    var region: String = ""
    var country: String = ""
    var reviewSource: String = ""
    var points: String = ""
    var review: String = ""
    var purchaseLots: NSMutableArray = []
    var locations: NSMutableArray = []
    
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
        locations.removeAllObjects()
    }
}
