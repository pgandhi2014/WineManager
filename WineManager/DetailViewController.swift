//
//  DetailViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/29/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var lotsLabel: UILabel!
    @IBOutlet weak var locationsLabel: UILabel!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var lotDescription = ""
        var locDescrption = ""
        
        let bottleDetails = self.detailItem as! Bottle
        if (bottleDetails.vintage! == 0) {
            nameLabel.text = "NV " + bottleDetails.name!
        } else {
            nameLabel!.text = String(bottleDetails.vintage!) + " " + bottleDetails.name!
        }
        regionLabel!.text = bottleDetails.varietal! + " from " + bottleDetails.region! + ", " + bottleDetails.country!
        for (_, value) in bottleDetails.lots!.enumerate() {
            let lot = value as! PurchaseLot
            if (lot.quantity == 1) {
                lotDescription = lotDescription + lot.quantity!.stringValue + " bottle on " + dateFormatter.stringFromDate(lot.purchaseDate!) + " for $" + lot.price!.stringValue + "\n"
            } else {
                lotDescription = lotDescription + lot.quantity!.stringValue + " bottles on " + dateFormatter.stringFromDate(lot.purchaseDate!) + " for $" + lot.price!.stringValue + "\n"
            }
        }
        lotsLabel!.text = lotDescription
        for (_, value) in bottleDetails.statuses!.enumerate() {
            let loc = value as! Status
            if (loc.available == 1) {
                locDescrption = locDescrption + "Stored in " + loc.location! + "\n"
            } else {
                locDescrption = locDescrption + loc.rating!.stringValue + " stars on " + dateFormatter.stringFromDate(loc.drunkDate!)
            }
        }
        locationsLabel!.text = locDescrption


    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let details = self.detailItem as! Bottle
        NSLog(details.name!)
        NSLog(String(details.vintage!))
        NSLog(details.varietal!)
        NSLog(details.region!)
        NSLog(details.country!)
        NSLog(details.review!)
        for (_, value) in details.lots!.enumerate() {
            let lot = value as! PurchaseLot
            NSLog(lot.price!.stringValue)
            NSLog(lot.quantity!.stringValue)
            NSLog(dateFormatter.stringFromDate(lot.purchaseDate!))
        }
        for (_, value) in details.statuses!.enumerate() {
            let loc = value as! Status
            NSLog(loc.location!)
            NSLog(dateFormatter.stringFromDate(loc.drunkDate!))
            NSLog(loc.available!.stringValue)
            NSLog(loc.notes!)
            NSLog(loc.rating!.stringValue)
        }
        self.configureView()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

