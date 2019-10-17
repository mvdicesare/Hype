//
//  Hype.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit
// MARK: - Hype Strings
struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let userReferanceKey = "userReferance"
    fileprivate static let photoAsseetKey = "photoAsset"
}
// MARK: - Class Declarations
class Hype {
    
    var body: String
    var timestamp: Date
    let ckRecordID: CKRecord.ID
    let userReference: CKRecord.Reference
    
    var hypePhoto: UIImage? {
        get {
            guard let data = photoData else {return nil}
            return UIImage(data: data)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    var photoAsset: CKAsset? {
        guard photoData != nil else { return nil }
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
    
    
    init(body: String, timestamp: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference, hypePhoto: UIImage? = nil) {
        self.body = body
        self.timestamp = timestamp
        self.ckRecordID = ckRecordID
        self.userReference = userReference
        self.hypePhoto = hypePhoto
    }
}
/// Cloud -> Hype
// MARK: - Convenience init Extiontion
extension Hype {
    /**
     Convenience failable initalizer that finds the keyValue pairs in the passed in CKRecords and initalzies a Hype from those
        - Parameters:
            - ckRecord: CKRecord object should contain the key/value pairs of a Hype object store in the Cloud
     */
    convenience init?(ckRecord: CKRecord){
        //unwraping the values for the keys stored in the CKRecord
      guard let body = ckRecord[HypeStrings.bodyKey] as? String,
        let timestamp = ckRecord[HypeStrings.timestampKey] as? Date,
        let userReference = ckRecord[HypeStrings.userReferanceKey] as? CKRecord.Reference
        else { return nil }
        var hypePhoto: UIImage?
        if let photoAsset = ckRecord[HypeStrings.photoAsseetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                hypePhoto = UIImage(data: data)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        self.init(body: body, timestamp: timestamp, ckRecordID: ckRecord.recordID, userReference: userReference, hypePhoto: hypePhoto)
    }
}
/// Hype -> Cloud
// MARK: - CKRecord Extention
extension CKRecord {
    /**
     Convenience initalizer to create a CKRecord and set the key/value pairs based on our Hype model objects
     - Parameters:
        - hype: Hype object that we want to set CKRecord key/value pairs for
     */
    convenience init(hype: Hype) {
        //initalizes a CKRecord
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.ckRecordID)
        // set the key/value pairs for the CKRecord
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp,
            HypeStrings.userReferanceKey: hype.userReference
        ])
        if hype.photoAsset != nil {
            self.setValue(hype.photoAsset, forKey: HypeStrings.photoAsseetKey)
        }
    }
}

// MARK: - Equatable
extension Hype: Equatable {
    static func == (lhs: Hype, rhs: Hype) -> Bool {
      //  return lhs === rhs or
        return lhs.ckRecordID == rhs.ckRecordID
    }
}
