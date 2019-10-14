//
//  Hype.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit
// MARK: - Hype Strings
struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}
// MARK: - Class Declarations
class Hype {
    
    var body: String
    var timestamp: Date
    
    init(body: String, timestamp: Date = Date()){
        self.body = body
        self.timestamp = timestamp
    }
}
/// Cloud -> Hype
// MARK: - Convenience init Extiontion
extension Hype {
    /**
     Convenience failable initalizer that finds the keyValue pairs in the passed in CKRecords and initalzies a Hype from those
        - Parameters:
            - ckRecord: CKRecord object shou;d contain the key/value pairs of a Hype object store in the Cloud
     */
    convenience init?(ckRecord: CKRecord){
        //unwraping the values for the keys stored in the CKRecord
      guard let body = ckRecord[HypeStrings.bodyKey] as? String,
        let timestamp = ckRecord[HypeStrings.timestampKey] as? Date else { return nil }
        self.init(body: body, timestamp: timestamp )
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
        self.init(recordType: HypeStrings.recordTypeKey)
        // set the key/value pairs for the CKRecord
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
        
    }
}
