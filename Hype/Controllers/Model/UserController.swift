//
//  UserController.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/16/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class UserController {
    //Singleton
    static let shared = UserController()
    // SOT
    var currentUser: User?
    // Class properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD
    // create
    func createUserWith(username: String, profilePhoto: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        //  Fetches and returns a referance to the currently logged in apple id user
        fetchAppleUserReference { (reference) in
            // Ensure we get the referance back
            guard let reference = reference else {completion(false); return}
            // step 1 - init the user we want to save
            let newUser = User(username: username, appleUserReference: reference, profilePhoto: profilePhoto)
            // step 2 turn it into a recod
            let record = CKRecord(user: newUser)
            // step 3 call the saved record on the database and pass in the record
            self.publicDB.save(record) { (record, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let savedRecord = record,
                    let savedUser = User(ckRecord: savedRecord)
                    else {completion(false); return}
                self.currentUser = savedUser
                print("Created user : \(savedRecord.recordID.recordName)")
                completion(true)
            }
        }
    }
    func fetchUser(completion: @escaping (_ success: Bool) -> Void) {
        // step 4 fetching the reference needed fot the arguments array in step 3 
        fetchAppleUserReference { (reference) in
            guard let reference = reference else {completion(false); return}
            // step 3 creating the predicate, using an array of arguments, needed for step 2
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserRefKey, reference ])
            // step 2 - Creating the query needed for step 1 which needs a predicate
            let query = CKQuery(recordType: UserStrings.typeKey, predicate: predicate)
            // step 1 - Calling the perform on publicData base, which needs a Query
            self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let record = records?.first,
                let foundUser = User(ckRecord: record)
                    else {completion(false); return}
                self.currentUser = foundUser
                print("Fetched User: \(record.recordID.recordName) successfully")
                completion(true)
            }
        }
    }
    func fetchUserFor(_ hype: Hype, completion: @escaping (User?)-> Void){
        let userID = hype.userReference.recordID
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["recordID", userID ])
        let query = CKQuery(recordType: UserStrings.typeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            guard let record = records?.first,
            let foundUser = User(ckRecord: record)
                else { completion(nil) ; return }
            print("User was found")
            completion(foundUser)
        }
    }
    // fetch
    private func fetchAppleUserReference(completion: @escaping (_ reference: CKRecord.Reference?)-> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let recordID = recordID else {completion(nil) ; return}
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(reference)
        }
    }
}
