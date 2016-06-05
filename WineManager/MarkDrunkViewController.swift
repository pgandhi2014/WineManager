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
    func saveDrunkInfo(rating: Float, date: NSDate)
}


class MarkDrunkViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    let step: Float = 0.5
    var bottleName: String?
    var delegate : SavingDrunkViewControllerDelegate?
    
    @IBAction func dismissButtonPress(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPress(sender: AnyObject) {
        if((self.delegate) != nil)
        {
            delegate?.saveDrunkInfo(ratingSlider.value, date: datePicker.date)
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
    }

}
