//
//  CustomPrototypeCell.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/7/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit


class CustomPrototypeCell: UITableViewCell {
    
    
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    
    func colorCell(color: UIColor) {
        lblName.textColor = color
        lblDetails.textColor = color
        lblRating.textColor = color
        lblRating.layer.borderColor = color.CGColor
        lblRating.layer.borderWidth = 2.0
        lblRating.layer.cornerRadius = 20
    }
    
    
}