//
//  CloudHelper.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 8/4/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import CloudKit
import CoreData
import UIKit

private let _sharedInstance = CloudHelper()

protocol UploadPendingDelegate
{
    func uploadPendingWithCount(count: Int)
}


class CloudHelper: NSObject {
    
    let dateFormatter = NSDateFormatter()
    let container = CKContainer.defaultContainer()
    var privateDatabase : CKDatabase? = nil
    var delegate : UploadPendingDelegate?
    var recordsToUpload = [CKRecord]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    private override init() {
        super.init()
        dateFormatter.dateFormat = "MMddyyyy"
        privateDatabase = container.privateCloudDatabase
    }
    
    class var sharedInstance: CloudHelper {
        return _sharedInstance
    }
    
    func addRecordToUpload(record: CKRecord) {
        recordsToUpload.append(record)
        let newRecordEntity = NSEntityDescription.insertNewObjectForEntityForName("DirtyRecord", inManagedObjectContext: appDelegate.managedObjectContext) as! DirtyRecord
        print(record.recordType)
        print(record.recordID.recordName)
        newRecordEntity.id = record.recordID.recordName
        newRecordEntity.type = record.recordType
        saveContext()
        if((self.delegate) != nil)
        {
            delegate?.uploadPendingWithCount(numberOfRecordsToUpload())
        }
    }
    
    func removeAllRecordsToUpload() {
        recordsToUpload.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "DirtyRecord")
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try appDelegate.persistentStoreCoordinator.executeRequest(delete, withContext: appDelegate.managedObjectContext)
        } catch let error as NSError {
            print("Error occured while deleting: \(error)")
        }
        
        if((self.delegate) != nil)
        {
            delegate?.uploadPendingWithCount(numberOfRecordsToUpload())
        }
    }
    
    func numberOfRecordsToUpload() -> Int {
        return recordsToUpload.count
    }
    
    func getRecordForWine(entity: Wine, shouldPopulate: Bool) -> CKRecord {
        let recordName = entity.id!
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: "Wine", recordID: recordID)
        if (shouldPopulate) {
            record["availableBottles"] = entity.availableBottles!.integerValue
            record["country"] = entity.country!
            record["drunkBottles"] = entity.drunkBottles!.integerValue
            record["lastDrunkDate"] = entity.lastDrunkDate!
            record["lastPurchaseDate"] = entity.lastPurchaseDate!
            record["maxPrice"] = entity.maxPrice!.doubleValue
            record["name"] = entity.name!
            record["points"] = entity.points!.integerValue
            record["region"] = entity.region!
            record["review"] = entity.review!
            record["reviewSource"] = entity.reviewSource!
            record["varietal"] = entity.varietal!
            record["vintage"] = entity.vintage!.integerValue
        }
        return record
    }
    
    func getRecordForLot(entity: PurchaseLot, shouldPopulate: Bool) -> CKRecord {
        let recordName = entity.id!
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: "PurchaseLot", recordID: recordID)
        if (shouldPopulate) {
            let wine = entity.wine!
            let wineRecord = getRecordForWine(wine, shouldPopulate: false)
            let reference = CKReference(recordID: wineRecord.recordID, action: .DeleteSelf)
            record["availableBottles"] = entity.availableBottles!.integerValue
            record["drunkBottles"] = entity.drunkBottles!.integerValue
            record["price"] = entity.price!.doubleValue
            record["purchaseDate"] = entity.purchaseDate!
            record["quantity"] = entity.quantity!.integerValue
            record["wine"] = reference
        }
        return record
    }
    
    func getRecordForBottle(entity: Bottle, shouldPopulate: Bool) -> CKRecord {
        let recordName = entity.id!
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: "Bottle", recordID: recordID)
        if (shouldPopulate) {
            let lot = entity.lot!
            let lotRecord = getRecordForLot(lot, shouldPopulate: false)
            let reference = CKReference(recordID: lotRecord.recordID, action: .DeleteSelf)
            record["available"] = entity.available!.integerValue
            record["location"] = entity.location
            record["rating"] = entity.rating!.doubleValue
            record["drunkDate"] = entity.drunkDate!
            record["lot"] = reference
        }
        return record
    }
    
//    func saveEntityToCloud(entity: NSManagedObject, ofType: String) {
//        var recordToSave: CKRecord? = nil
//        if (ofType == "Wine") {
//            recordToSave = getRecordForWine(entity as! Wine, shouldPopulate: true)
//        } else if (ofType == "Lot") {
//            recordToSave = getRecordForLot(entity as! PurchaseLot, shouldPopulate: true)
//        } else if (ofType == "Bottle") {
//            recordToSave = getRecordForBottle(entity as! Bottle, shouldPopulate: true)
//        }
//        
//        privateDatabase!.saveRecord(recordToSave!) { (record, error) in
//            if error != nil {
//                print("There was an error: \(error)")
//            } else {
//                print (record!.recordID.recordName + "saved")
//            }
//        }
//    }
    
//    func modifyEntityInCloud(entity: NSManagedObject, ofType: String) {
//        var recordToSave: CKRecord? = nil
//        if (ofType == "Wine") {
//            recordToSave = getRecordForWine(entity as! Wine, shouldPopulate: false)
//        } else if (ofType == "Lot") {
//            recordToSave = getRecordForLot(entity as! PurchaseLot, shouldPopulate: false)
//        } else if (ofType == "Bottle") {
//            recordToSave = getRecordForBottle(entity as! Bottle, shouldPopulate: false)
//        }
//        
//        privateDatabase!.fetchRecordWithID(recordToSave!.recordID, completionHandler: { (record, error) in
//            if error != nil {
//                print("Error fetching record: \(error!.localizedDescription)")
//            } else {
//                var modifiedRecord: CKRecord? = nil
//                if (ofType == "Wine") {
//                    modifiedRecord = self.modifyWineRecord(record!, wine: entity as! Wine)
//                } else if (ofType == "Lot") {
//                    modifiedRecord = self.modifyLotRecord(record!, lot: entity as! PurchaseLot)
//                } else if (ofType == "Bottle") {
//                    modifiedRecord = self.modifyBottleRecord(record!, bottle: entity as! Bottle)
//                }
//                
//                // Save this record again
//                self.privateDatabase!.saveRecord(modifiedRecord!, completionHandler: { (savedRecord, saveError) in
//                    if saveError != nil {
//                        print("Error saving record: \(saveError!.localizedDescription)")
//                    } else {
//                        print("Successfully updated record!")
//                    }
//                })
//            }
//        })
//    }
//    
//    private func modifyBottleRecord(record: CKRecord, bottle: Bottle) -> CKRecord {
//        record.setObject(bottle.location!, forKey: "location")
//        record.setObject(bottle.available!, forKey: "available")
//        record.setObject(bottle.rating!, forKey: "rating")
//        record.setObject(bottle.drunkDate!, forKey: "drunkDate")
//        return record
//    }
//    
//    private func modifyWineRecord(record: CKRecord, wine: Wine) -> CKRecord {
//        record.setObject(wine.availableBottles!, forKey: "availableBottles")
//        record.setObject(wine.lastPurchaseDate!, forKey: "lastPurchaseDate")
//        record.setObject(wine.drunkBottles!, forKey: "drunkBottles")
//        record.setObject(wine.lastDrunkDate!, forKey: "lastDrunkDate")
//        record.setObject(wine.maxPrice!, forKey: "maxPrice")
//        return record
//    }
//    
//    private func modifyLotRecord(record: CKRecord, lot: PurchaseLot) -> CKRecord {
//        record.setObject(lot.availableBottles!, forKey: "availableBottles")
//        record.setObject(lot.drunkBottles!, forKey: "drunkBottles")
//        return record
//    }

//    func saveRecords(records: [CKRecord]) {
//        let updateOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
//        updateOperation.savePolicy = .ChangedKeys
//        updateOperation.perRecordCompletionBlock = { record, error in
//            if error != nil {
//                print("Unable to modify record: \(record). Error: \(error)")
//            }
//        }
//        updateOperation.modifyRecordsCompletionBlock = { saved, _, error in
//            if error != nil {
//                print(error)
//            } else {
//                print("saved All")
//            }
//        }
//        self.privateDatabase!.addOperation(updateOperation)
//    }

    func uploadRecords() {
        let count = numberOfRecordsToUpload()
        if (count < 300) {
            uploadArrayOfRecords(recordsToUpload)
        } else if (count < 600) {
            let splitRecords = recordsToUpload.split()
            uploadArrayOfRecords(splitRecords.left)
            sleep(10)
            uploadArrayOfRecords(splitRecords.right)
        } else if (count < 1200) {
            let splitRecords = recordsToUpload.split()
            let splitLeft = splitRecords.left.split()
            let splitRight = splitRecords.right.split()
            uploadArrayOfRecords(splitLeft.left)
            sleep(10)
            uploadArrayOfRecords(splitLeft.right)
            sleep(10)
            uploadArrayOfRecords(splitRight.left)
            sleep(10)
            uploadArrayOfRecords(splitRight.right)
        }
    }
    
    func uploadArrayOfRecords(records: [CKRecord]) {
        print("Uploading records: " + String(records.count))
        let updateOperation = CKModifyRecordsOperation(recordsToSave: recordsToUpload, recordIDsToDelete: nil)
        updateOperation.savePolicy = .ChangedKeys
        updateOperation.perRecordCompletionBlock = { record, error in
            if error != nil {
                print("Unable to modify record: \(record). Error: \(error)")
            }
        }
        updateOperation.modifyRecordsCompletionBlock = { saved, _, error in
            if error != nil {
                print(error)
            } else {
                print("Uploaded All")
                self.removeAllRecordsToUpload()
            }
        }
        self.privateDatabase!.addOperation(updateOperation)
    }
    
    func saveContext() {
        do {
            try appDelegate.managedObjectContext.save()
        } catch {
            abort()
        }
    }

}