//
//  CustomPrototypeCell.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/7/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit


class CustomPrototypeCell: UITableViewCell {
    
    
    @IBOutlet weak var lblSecondary: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    func colorCell(color: UIColor) {
        lblName.textColor = color
        lblDetails.textColor = color
        lblSecondary.textColor = color
    }
}