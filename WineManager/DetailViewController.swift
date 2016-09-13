//
//  DetailViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/29/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

protocol DetailViewControllerDelegate
{
    func BottleDetailsDidChange(dataChanged: Bool)
}


class DetailViewController: UIViewController, SavingDrunkViewControllerDelegate, EditLocationsViewControllerDelegate  {

    var delegate : DetailViewControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var lotsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var drunkLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewView: UITextView!
    @IBOutlet weak var drunkHistoryLabel: UILabel!
    @IBOutlet weak var locationHistoryLabel: UILabel!

    @IBOutlet weak var drunkHistoryWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var drunkLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var drunkHistorySpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locationHistoryWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabelWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var locationHistorySpacingConstraint: NSLayoutConstraint!


    @IBOutlet weak var markDrunkButton: UIBarButtonItem!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var drunkArray : [(date: NSDate, rating: Double)] = []
    var locationArray = Set<String>()
    
    var detailItem: AnyObject? {
        didSet {
            if (self.isViewLoaded()) {
                self.configureView()
            }
        }
    }

    func configureView() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var lotDescription = ""
        var drunkDescription = ""
        var locDescription = ""
        locationArray.removeAll()
        drunkArray.removeAll()
        
        let sorter = NSSortDescriptor(key: "purchaseDate", ascending: false)

        if let bottle = detailItem {
            let bottleDetails = bottle as! Wine
            ratingLabel!.text = bottleDetails.points!.stringValue + " pts by " + bottleDetails.reviewSource!
            reviewView!.text = bottleDetails.review!
    
            if (bottleDetails.vintage! == 0) {
                nameLabel.text = "NV " + bottleDetails.name!
            } else {
                nameLabel!.text = String(bottleDetails.vintage!) + " " + bottleDetails.name!
            }
            regionLabel!.text = bottleDetails.varietal! + " from " + bottleDetails.region! + ", " + bottleDetails.country!
            
            let sortedLots = bottleDetails.lots!.sortedArrayUsingDescriptors([sorter])
            for (index, value) in sortedLots.enumerate() {
                let lot = value as! PurchaseLot
                if (index > 0) {
                    lotDescription = lotDescription + "\n"
                }
                if (lot.quantity == 1) {
                    lotDescription = lotDescription + lot.quantity!.stringValue + " bottle on " + dateFormatter.stringFromDate(lot.purchaseDate!) + " for $" + lot.price!.stringValue
                } else {
                    lotDescription = lotDescription + lot.quantity!.stringValue + " bottles on " + dateFormatter.stringFromDate(lot.purchaseDate!) + " for $" + lot.price!.stringValue + " each"
                }
                
                for (_, value) in lot.bottles!.enumerate() {
                    let loc = value as! Bottle
                    if (loc.available == 0) {
                        drunkArray.append((date: loc.drunkDate!, rating: loc.rating!.doubleValue))
                    } else {
                        locationArray.insert(loc.location!)
                    }
                }
            }
        }
        lotsLabel!.text = lotDescription
        drunkArray.sortInPlace {
            return $0.date.compare($1.date) == NSComparisonResult.OrderedDescending
        }
        for (_, value) in drunkArray.enumerate() {
            if (drunkDescription.isEmpty) {
                drunkDescription = String(value.rating) + " stars on " + dateFormatter.stringFromDate(value.date)
            } else {
                drunkDescription = drunkDescription + "\n" + String(value.rating) + " stars on " + dateFormatter.stringFromDate(value.date)
            }
        }
        if (drunkDescription.isEmpty) {
            drunkLabelWidthConstraint.constant = 0.0
            drunkHistoryWidthConstraint.constant = 0.0
            drunkHistorySpacingConstraint.constant = 0.0
        } else {
            drunkLabelWidthConstraint.constant = 21.0 * CGFloat(drunkArray.count)
            drunkHistoryWidthConstraint.constant = 21.0
            drunkHistorySpacingConstraint.constant = 10.0
            drunkLabel!.text = drunkDescription
        }
            
        for (_, value) in locationArray.enumerate() {
            if (locDescription.isEmpty) {
                locDescription = value
            } else {
                locDescription = locDescription + ", " + value
            }
        }
        if (locDescription.isEmpty) {
            locationLabelWidthContraint.constant = 0.0
            locationHistoryWidthContraint.constant = 0.0
            locationHistorySpacingConstraint.constant = 0.0
            markDrunkButton.enabled = false
        } else {
            locationLabel!.text = locDescription
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        (self.parentViewController as! UINavigationController).setToolbarHidden(false, animated: true)
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let viewSize: CGRect = reviewView.bounds
        let screenHeightNeeded = viewSize.height + CGFloat(200.0)
        scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeightNeeded)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let bottle = detailItem as! Wine
        if segue.identifier == "showMarkDrunk" {
            let controller = segue.destinationViewController as! MarkDrunkViewController
            controller.bottleName = bottle.name!
            controller.bottleLocations = locationArray
            controller.delegate = self
        }
        if segue.identifier == "showEditDetails" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! AddEditViewController
            controller.bottleInfo = self.detailItem
            controller.viewMode = "Edit"
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.delegate = self
            controller.title = bottle.vintage!.stringValue + " " + bottle.name!
        }
    }
    
    func applyLocationChanges(dataChanged: Bool) {
        if (dataChanged) {
            self.configureView()
            if((self.delegate) != nil)
            {
                delegate?.BottleDetailsDidChange(dataChanged)
            }
        }
    }
    
    func saveDrunkInfo(rating: Float, date: NSDate, location: String) {
        var flagDone = false
        let wine = detailItem as! Wine
        for (_, value) in wine.lots!.enumerate() {
            let lot = value as! PurchaseLot
            for (_, value) in lot.bottles!.enumerate() {
                let bottle = value as! Bottle
                if (bottle.available! == 1 && bottle.location! == location && !flagDone) {
                    bottle.modifiedDate = NSDate()
                    bottle.available = 0
                    bottle.location = ""
                    bottle.drunkDate! = date
                    bottle.rating! = NSDecimalNumber(float: rating)
                    lot.modifiedDate = NSDate()
                    lot.availableBottles = (lot.availableBottles?.integerValue)! - 1
                    lot.drunkBottles = (lot.drunkBottles?.integerValue)! + 1
                    wine.modifiedDate = NSDate()
                    wine.availableBottles! = (wine.availableBottles?.integerValue)! - 1
                    wine.drunkBottles! = (wine.drunkBottles?.integerValue)! + 1
                    wine.lastDrunkDate! = date
                    flagDone = true
                    break
                }
            }
        }
    saveContext()
    }
    
    func saveContext() {
        do {
            try appDelegate.managedObjectContext.save()
        } catch {
            abort()
        }
    }


}

