//
//  MarkDrunkViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/5/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit

protocol SavingDrunkViewControllerDelegate
{
    func saveDrunkInfo(rating: Float, date: NSDate, location: String)
}


class MarkDrunkViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var locationSelectionSegment: UISegmentedControl!
    
    @IBOutlet weak var locationSelectionHeightConstraint: NSLayoutConstraint!
    let step: Float = 0.5
    var bottleName: String?
    var bottleLocations = Set<String>()
    var delegate : SavingDrunkViewControllerDelegate?
    
    @IBAction func dismissButtonPress(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPress(sender: AnyObject) {
        if((self.delegate) != nil)
        {
            var location = ""
            if (bottleLocations.count == 1) {
                location = bottleLocations.first! as String
            } else {
                location = locationSelectionSegment.titleForSegmentAtIndex(locationSelectionSegment.selectedSegmentIndex)!
            }
            delegate?.saveDrunkInfo(ratingSlider.value, date: datePicker.date, location: location)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func ratingSliderValueChanged(sender: UISlider) {
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        ratingLabel.text = String(roundedValue) + " stars"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nameLabel.text = bottleName
        if (bottleLocations.count > 1) {
            locationSelectionSegment.removeAllSegments()
            for (index, value) in bottleLocations.enumerate() {
                locationSelectionSegment.insertSegmentWithTitle(value, atIndex: index, animated: false)
            }
            locationSelectionSegment.selectedSegmentIndex = 0
        } else {
            locationSelectionSegment.hidden = true;
            locationSelectionHeightConstraint.constant = 0.0
        }
    }

}
