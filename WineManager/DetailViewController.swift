//
//  DetailViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/29/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var lotsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var drunkLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewView: UITextView!

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
        var drunkDescription = ""
        var locDescription = ""
        
        let bottleDetails = self.detailItem as! Bottle
        if (bottleDetails.vintage! == 0) {
            nameLabel.text = "NV " + bottleDetails.name!
        } else {
            nameLabel!.text = String(bottleDetails.vintage!) + " " + bottleDetails.name!
        }
        regionLabel!.text = bottleDetails.varietal! + " from " + bottleDetails.region! + ", " + bottleDetails.country!
        let totalLots = bottleDetails.lots!.count
        lotsLabel.numberOfLines = totalLots
        
        for (index, value) in bottleDetails.lots!.enumerate() {
            let lot = value as! PurchaseLot
            if (lot.quantity == 1) {
                lotDescription = lotDescription + lot.quantity!.stringValue + " bottle on " + dateFormatter.stringFromDate(lot.purchaseDate!) + " for $" + lot.price!.stringValue + "\n"
            } else {
                lotDescription = lotDescription + lot.quantity!.stringValue + " bottles on " + dateFormatter.stringFromDate(lot.purchaseDate!) + " for $" + lot.price!.stringValue + "\n"
            }
            if (index == totalLots - 1) {
                lotDescription = lotDescription.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            }
        }
        lotsLabel!.text = lotDescription
        
        let totalBottles = bottleDetails.statuses!.count
        drunkLabel.numberOfLines = totalBottles
        for (index, value) in bottleDetails.statuses!.enumerate() {
            let loc = value as! Status
            if (loc.available == 0) {
                drunkDescription = drunkDescription + loc.rating!.stringValue + " stars on " + dateFormatter.stringFromDate(loc.drunkDate!) + "\n"
            }
            if (index == totalBottles - 1) {
                drunkDescription = drunkDescription.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            }
        }
        drunkLabel!.text = drunkDescription

        locationLabel.numberOfLines = totalBottles
        for (index, value) in bottleDetails.statuses!.enumerate() {
            let loc = value as! Status
            if (loc.available == 1) {
                locDescription = locDescription + loc.location! + ", "
                }
            if (index == totalBottles - 1) {
                locDescription = locDescription.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: ", "))
            }
        }
        locationLabel!.text = locDescription

        ratingLabel!.text = bottleDetails.points!.stringValue + " pts by " + bottleDetails.reviewSource!
        reviewView!.text = bottleDetails.review!

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        (self.parentViewController as! UINavigationController).setToolbarHidden(false, animated: true)
        scrollView.contentSize = CGSize(width: 1200, height: 2200)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

