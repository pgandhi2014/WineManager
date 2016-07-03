//
//  LotEntity.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/1/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit

struct ALot {
    var purchaseDate: NSDate = NSDate()
    var bottlePrice: Float = 0.0
    var totalBottles: Int = 0
    var locations = [String:Int]()
}

