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


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("review")!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
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
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

