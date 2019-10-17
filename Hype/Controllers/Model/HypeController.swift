//
//  HypeController.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class HypeController {
    // shared instance
    static let shared = HypeController()
    let publicDB = CKContainer.default().publicCloudDatabase
    // source of truth
    var hypes: [Hype] = []
    //CRUD
    
    
    //CREATE
    /**
     Saves a Hype Object to the cloud public database
     - Parameters:
     - text: String value for the hype'd body
     - Completion: Escaping completion block for the method
     - sucess: Boolean calue returned in the completion block indication success or failure on saving the CKRecord to CloudKit and reinitalizin as the Object
     */
    func saveHype(with text: String, photo: UIImage?, completion: @escaping (_ success: Bool)-> Void) {
      
        guard let currentUser = UserController.shared.currentUser else {completion(false); return}
        let reference = CKRecord.Reference(recordID: currentUser.ckRecordID, action: .deleteSelf)
          // Declares newHype, Assignes it to an initalized Hype object, taking the text parameter and passing it in for the body
        let newHype = Hype(body: text, userReference: reference, hypePhoto: photo )
        // Initalizes a new CKRecord with a Hype using our convenience init on CKRecord extension
        let hypeRecord = CKRecord(hype: newHype)
        // access the save method on our database to save the hypeRecord, completes with an opitional record and error
        publicDB.save(hypeRecord) { (record, error) in
            //Handling the error. If there is one , print the discription nd complete false
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // unwrap the record that was saved, then turning into our model object using our failible convienience initializer
            guard let record = record,
                let savedHype = Hype(ckRecord: record)
                else { completion(false); return }
            // appending the savedHype to our SOT, completing true
            self.hypes.append(savedHype)
            completion(true)
        }
    }
    //FETCH OR ADD
    func fetchAllHypes(completion: @escaping (_ sucess: Bool) -> Void) {
        // step 3 - Creating a predocate to pass into the CKQuery
        let predicate = NSPredicate(value: true)
        // Step # Creating a query constant and assigning it to a CKQuery, initalized with out recordTypeKey and it requires a predpreicate
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        //step 1 Calls the perform method on the public DB, which requires a CKQuery
        publicDB.perform(query, inZoneWith: nil) { (foundRecords, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // check to make sure we recieved records, if not complete false and return
            guard let records = foundRecords else {
                completion(false) ; return }
            // Creating an array of hypes from the records array , compactMapping through it to return the non - nill value.
            let hypes = records.compactMap( { Hype(ckRecord: $0) } )
            // asign out SOT and Complete true
            self.hypes = hypes
            print("Fetched hypes successfully ")
            completion(true)
        }
    }
    func update(_ hype: Hype, completion: @escaping (_ success: Bool) -> Void) {
        // declaring the record that we would like to update and passing it into our operation
        let recordToUpdate = CKRecord(hype: hype)
        // step 2 - created our operation, which requires an array of records to save
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate], recordIDsToDelete: nil)
        // step 4 adjusting the properties for the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            // handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // make sure our record that was updated matches the record we passed in, completes trye if it does
            guard recordToUpdate == records?.first else {
                print("Unexpected record was updated")
                completion(false)
                return
            }
            print("Updated \(recordToUpdate.recordID) successfully in cloud kit")
            completion(true)
        }
        // step 1 calling the add method on our public data base which requires an operation
        publicDB.add(operation)
    }
    func delete(_ hype: Hype, completion: @escaping (_ success: Bool) -> Void) {
        // step 2 - Defining the operatiojn, and passing in the array of records id to delete
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.ckRecordID])
        // step 3 Set Properties of our operation
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = { _, recordIDs, error in
            // handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // comparing our hype recordID that we wanted to delete to the recordID  that was deleted. if they match we complete true.
            guard hype.ckRecordID == recordIDs?.first else {
                print("unexpected recordID was deleted")
                completion(false)
                return
            }
            print("Successfully deleted Hype from Cloud Kit ")
            completion(true)
        }
        // step one calling add on the publicDb, that requires and operation
        publicDB.add(operation)
    }
    func slowDelete(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        // calling delete on the PublicDB, passing the recordID that we want to delete
        publicDB.delete(withRecordID: hype.ckRecordID) { (recordID, error) in
            // handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // Check to make sure the recordID was deleted and removed from the sot
            if recordID != nil {
                guard let index = self.hypes.firstIndex(of: hype) else {
                    completion(false); return }
                self.hypes.remove(at: index)
                
            }
        }
    }
    func subscribeForRemoteNotifications(completion: @escaping (_ error: Error?) -> Void) {
        // step 3 - Declaring the predicat with a true value  for our subscription
        let predicate = NSPredicate(value: true)
        //step 2 - declaring a subscription, giving it a type and a predicate
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        // step 4 tell notifivation what to look like
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't stop the hype train!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        // step 5 set the notifivation info  to the notification info in step 4
        subscription.notificationInfo = notificationInfo
        // step 1 - Calling save on the public db and passing in a subscription
        publicDB.save(subscription) { (_, error) in
            // handle our error and complete
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(error)
            }
            completion(nil)
        }
    }
}
