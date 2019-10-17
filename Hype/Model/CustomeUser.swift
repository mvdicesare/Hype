//
//  CustomeUser.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/16/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

struct UserStrings {
    static let typeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    static let appleUserRefKey = "appleUserReference"
    fileprivate static let photoAssetKey = "photoAsset"
}


class User {
    var username: String
    var bio: String
    
    let ckRecordID: CKRecord.ID
    let appleUserReference: CKRecord.Reference
    
    var profilePhoto: UIImage? {
        get {
            guard  let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    var photoAsset: CKAsset? {
        let tempDirectory = NSTemporaryDirectory()
        let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
        let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpeg")
        do {
            try photoData?.write(to: fileURL)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return CKAsset(fileURL: fileURL)
    }
    
    init(username: String, bio: String = "", ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference, profilePhoto: UIImage? = nil) {
        
        self.username = username
        self.bio = bio
        self.ckRecordID = ckRecordID
        self.appleUserReference = appleUserReference
        self.profilePhoto = profilePhoto
    }
}

// cloud to user
extension User {
    //Giving ourselves the avility ro init a user from ckrecord
    convenience init?(ckRecord: CKRecord) {
        // unwrap the valsues at the given keys, make sure they are the type that we want, other return nil
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
            let bio = ckRecord[UserStrings.bioKey] as? String,
            let reference = ckRecord[UserStrings.appleUserRefKey] as? CKRecord.Reference
            else {return nil }
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[UserStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset from data")
            }
        }
        
        // call the class init
        self.init(username: username, bio: bio, ckRecordID: ckRecord.recordID, appleUserReference: reference, profilePhoto: foundPhoto)
    }
}


// User to cloud
extension CKRecord {
    // giving our sevles a wat to init a CKRecord and pass in a user
    convenience init(user: User) {
        // init a ckrecord object, assign its  type as our user and its record id  as the user.ckRecordID passed in
        self.init(recordType: UserStrings.typeKey, recordID: user.ckRecordID)
        // set the values for the key from the user object that we passed in.
        setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.bioKey : user.bio,
            UserStrings.appleUserRefKey : user.appleUserReference
        ])
        if let asset = user.photoAsset {
            self.setValue(asset, forKey: UserStrings.photoAssetKey)
        }
        
    }
}

